--Chi tiết sản phẩm:
CREATE VIEW v_ChiTietSanPham_DayDu
AS
SELECT 
    SP.MaSP,
    SP.TenSP,
    SP.DonGia,
    SP.SoLuongTonKho,
    LSP.TenLoaiSP,
    NCC.TenNCC,
    NCC.DiaChi AS DiaChiNCC
FROM 
    SANPHAM AS SP
JOIN 
    LOAISANPHAM AS LSP ON SP.MaLoaiSP = LSP.MaLoaiSP
JOIN 
    NHACUNGCAP AS NCC ON SP.MaNCC = NCC.MaNCC;
GO

SELECT * FROM v_ChiTietSanPham_DayDu;

--Tổng hợp doanh thu theo từng đơn hàng:
CREATE VIEW v_TongHopDoanhThu_TheoDonHang
AS
SELECT 
    DH.MaDH,
    DH.NgayDat,
    DH.TrangThai,
    KH.HoTenKH,
    NV.HoTenNV,
    SUM(CT.SoLuong * CT.GiaBan) AS TongGiaTriDonHang
FROM 
    DONHANG AS DH
JOIN 
    KHACHHANG AS KH ON DH.MaKH = KH.MaKH
JOIN 
    NHANVIEN AS NV ON DH.MaNV = NV.MaNV
LEFT JOIN 
    CHITIETDONHANG AS CT ON DH.MaDH = CT.MaDH
GROUP BY
    DH.MaDH,
    DH.NgayDat,
    DH.TrangThai,
    KH.HoTenKH,
    NV.HoTenNV;
GO

SELECT * FROM v_TongHopDoanhThu_TheoDonHang;

--Thống kê sản phẩm bán chạy:
CREATE VIEW v_SanPhamBanChay
AS
SELECT 
    SP.MaSP,
    SP.TenSP,
    LSP.TenLoaiSP,
    SUM(CT.SoLuong) AS TongSoLuongBan
FROM 
    CHITIETDONHANG AS CT
JOIN 
    SANPHAM AS SP ON CT.MaSP = SP.MaSP
JOIN 
    LOAISANPHAM AS LSP ON SP.MaLoaiSP = LSP.MaLoaiSP
JOIN
    DONHANG AS DH ON CT.MaDH = DH.MaDH
WHERE 
    DH.TrangThai != N'Đã hủy'
GROUP BY 
    SP.MaSP,
    SP.TenSP,
    LSP.TenLoaiSP;
GO

--Top 5 sản phẩm bán chạy nhất:
SELECT TOP 5 * 
FROM v_SanPhamBanChay
ORDER BY TongSoLuongBan DESC;


------------------------------------------
---CÁC ĐỐI TƯỢNG CƠ SỞ DỮ LIỆU NÂNG CAO---
------------------------------------------

/* Tên chỉ mục: IDX_KH_DienThoai 
Mục đích: Tăng tốc độ truy vấn tìm kiếm khách hàng (KHACHHANG) dựa trên cột DienThoai.
Đây là một hoạt động tra cứu phổ biến khi khách hàng gọi đến tổng đài hoặc đăng nhập.
*/
CREATE INDEX IDX_KH_DienThoai
ON KHACHHANG(DienThoai);
GO
/* Tên chỉ mục: IDX_SP_TenSP
Mục đích: Tăng tốc độ tìm kiếm sản phẩm (SANPHAM) dựa trên TenSP
*/
CREATE NONCLUSTERED INDEX IDX_SP_TenSP
ON SANPHAM(TenSP);
GO

---TẠO THỦ TỤC----
/*-- Tên thủ tục: sp_CapNhatTrangThaiDonHang 
Mục đích: Cung cấp một giao diện an toàn để cập nhật trạng thái của một đơn hàng (DONHANG) mà không cần 
cấp quyền truy cập trực tiếp vào bảng.
*/
CREATE PROCEDURE sp_CapNhatTrangThaiDonHang
    @MaDH_input INT,
    @TrangThaiMoi NVARCHAR(50)
AS
BEGIN
    -- Kiểm tra xem MaDH có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM DONHANG WHERE MaDH = @MaDH_input)
    BEGIN
        PRINT N'LỖI: Mã đơn hàng không tồn tại.';
        RETURN; -- Dừng thủ tục
    END

    -- Cập nhật trạng thái
    UPDATE DONHANG
    SET TrangThai = @TrangThaiMoi
    WHERE MaDH = @MaDH_input;

    PRINT N'Cập nhật trạng thái đơn hàng thành công.';
END;
GO
--Ví dụ:
-- 1. Xem trạng thái trước khi gọi
SELECT MaDH, TrangThai FROM DONHANG WHERE MaDH = 3;

-- 2. Gọi thủ tục
EXEC sp_CapNhatTrangThaiDonHang @MaDH_input = 3, @TrangThaiMoi = N'Đang giao hàng';

-- 3. Xem trạng thái sau khi gọi
SELECT MaDH, TrangThai FROM DONHANG WHERE MaDH = 3;

---TẠO HÀM---
/*Tên hàm: fn_TinhTongGiaTriDonHang 
Mục đích: Một hàm vô hướng (Scalar Function) trả về 
tổng giá trị (thành tiền) của một đơn hàng cụ thể dựa trên MaDH được cung cấp.
*/
CREATE FUNCTION fn_TinhTongGiaTriDonHang (@MaDH_input INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @TongGiaTri MONEY;

    SELECT @TongGiaTri = SUM(SoLuong * GiaBan)
    FROM CHITIETDONHANG
    WHERE MaDH = @MaDH_input;

    -- Nếu đơn hàng không có chi tiết (bị lỗi), trả về 0
    RETURN ISNULL(@TongGiaTri, 0);
END;
GO

--Ví dụ lấy tổng giá trị của đơn hàng MaDH = 4:
SELECT dbo.fn_TinhTongGiaTriDonHang(4) AS TongGiaTriDonHangSo4;

---TẠO TRIGGER---
CREATE TRIGGER TRG_CapNhatTonKho_KhiDatHang
ON CHITIETDONHANG  
AFTER INSERT       
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra xem có đủ hàng tồn kho không
    IF EXISTS (
        SELECT 1
        FROM SANPHAM SP
        JOIN inserted i ON SP.MaSP = i.MaSP
        WHERE SP.SoLuongTonKho < i.SoLuong
    )
    BEGIN
        -- Nếu không đủ hàng, hủy giao dịch và báo lỗi
        ROLLBACK TRANSACTION;
        RAISERROR (N'Không đủ số lượng tồn kho cho một hoặc nhiều sản phẩm.', 16, 1);
        RETURN;
    END;

    -- Nếu đủ hàng, tiến hành cập nhật kho
    UPDATE SP
    SET SP.SoLuongTonKho = SP.SoLuongTonKho - i.SoLuong
    FROM SANPHAM SP
    JOIN inserted i ON SP.MaSP = i.MaSP;
END;
GO

--Ví dụ: 
--Trước khi trigger: 
SELECT SoLuongTonKho FROM SANPHAM WHERE MaSP = 'GD004'; 
--=>Kết quả: 250

--Trigger: Thêm 5 'Dép quai ngang nam Bitis' (GD004) vào Đơn hàng 8:
INSERT INTO CHITIETDONHANG (MaDH, MaSP, SoLuong, GiaBan)
VALUES (8, 'GD004', 5, 250000);

--Sau khi trigger: 
SELECT SoLuongTonKho FROM SANPHAM WHERE MaSP = 'GD004';
--=>Kết quả: Trigger đã tự động chạy và cập nhật thành công SoLuongTonKho (lấy 250 - 5 = 245).

---------------------------------------
---BẢO MẬT VÀ QUẢN TRỊ CƠ SỞ DỮ LIỆU---
---------------------------------------

/*Quản lý người dùng và quyền truy cập:
Mục tiêu: tạo một người dùng mới (UserBanHang) và chỉ cấp cho họ những quyền tối thiểu cần thiết để 
làm việc (nguyên tắc "least privilege").
*/
-- Bước 1: Tạo một Login (tài khoản đăng nhập vào SQL Server)
USE master;
GO
CREATE LOGIN NhanVienMoi WITH PASSWORD = 'StrongPassword123!';
GO

-- Bước 2: Tạo một User (ánh xạ Login đó vào CSDL QLHeThongBanHang)
USE QLHeThongBanHang;
GO
CREATE USER UserBanHang FOR LOGIN NhanVienMoi;
GO

-- Bước 3: Cấp quyền (GRANT) cho User đó
-- Cho phép UserBanHang XEM (SELECT) bảng Khách Hàng và Sản Phẩm
GRANT SELECT ON KHACHHANG TO UserBanHang;
GRANT SELECT ON SANPHAM TO UserBanHang;

-- Cho phép UserBanHang THÊM (INSERT) đơn hàng và chi tiết đơn hàng
GRANT INSERT ON DONHANG TO UserBanHang;
GRANT INSERT ON CHITIETDONHANG TO UserBanHang;
GO

-- Bước 4: Thu hồi/Chặn quyền (REVOKE/DENY)
-- Đảm bảo rằng User này KHÔNG BAO GIỜ được phép XÓA (DELETE) khách hàng
DENY DELETE ON KHACHHANG TO UserBanHang;
GO

/*Bảo mật cơ sở dữ liệu (dùng View)
Mục tiêu: che giấu các cột nhạy cảm (như NgaySinh của nhân viên) bằng cách tạo một View và chỉ cho 
người dùng xem View đó.
*/
-- Bước 1: Tạo View chỉ chứa thông tin không nhạy cảm
CREATE VIEW v_DanhBaNhanVien
AS
SELECT
    MaNV,
    HoTenNV,
    DienThoai,
    ViTriCongViec
FROM
    NHANVIEN;
GO

-- Bước 2: Cấp quyền cho người dùng (ví dụ: UserBanHang)
-- Họ chỉ được xem View này, không được xem bảng NHANVIEN gốc
GRANT SELECT ON v_DanhBaNhanVien TO UserBanHang;
DENY SELECT ON NHANVIEN TO UserBanHang; -- Chặn quyền xem bảng gốc
GO

-- Bước 3: Người dùng UserBanHang giờ chỉ có thể xem thông tin này
-- (Nếu UserBanHang chạy lệnh này, nó sẽ hoạt động)
SELECT * FROM v_DanhBaNhanVien;

-- (Nếu UserBanHang chạy lệnh này, nó sẽ báo lỗi "Permission denied")
-- SELECT * FROM NHANVIEN;

/*Quản lý sao lưu và phục hồi:
Mục đích: Sao lưu (backup) và phục hồi (restore) toàn bộ cơ sở dữ liệu
*/
-- 1. SAO LƯU (Backup)
-- Sao lưu toàn bộ (Full Backup) cơ sở dữ liệu
BACKUP DATABASE QLHeThongBanHang
TO DISK = 'D:\Backups\QLHeThongBanHang_Full.bak'
WITH NAME = 'Full Backup of QLHeThongBanHang';
GO

-- 2. PHỤC HỒI (Restore)
-- (Lưu ý: Bạn phải ở trong CSDL 'master' để phục hồi)
USE master;
GO
-- Lệnh này sẽ NGẮT KẾT NỐI tất cả người dùng khác khỏi CSDL
-- và phục hồi CSDL từ tệp sao lưu
RESTORE DATABASE QLHeThongBanHang
FROM DISK = 'D:\Backups\QLHeThongBanHang_Full.bak'
WITH REPLACE, RECOVERY;
GO

/*Quản lý hiệu suất (dùng Index)
Mục tiêu: tăng tốc độ truy vấn.
*/
-- 1. Câu truy vấn (CHƯA có Index)
-- SQL Server sẽ phải "quét" toàn bộ bảng KHACHHANG để tìm số này
-- (Cái này gọi là "Table Scan" - rất chậm nếu có hàng triệu khách hàng)
SELECT * FROM KHACHHANG
WHERE DienThoai = '0922222222'; -- Tìm khách hàng 'Nguyễn Mạnh Chiến'


-- 2. Tạo Index để tăng tốc
-- Lệnh này tạo một "mục lục" cho cột DienThoai, giúp tìm kiếm gần như tức thì
CREATE NONCLUSTERED INDEX IDX_KH_DienThoai
ON KHACHHANG(DienThoai);
GO

-- 3. Câu truy vấn (ĐÃ có Index)
-- Bây giờ, khi chạy lại câu lệnh y hệt bên trên,
-- SQL Server sẽ dùng Index (gọi là "Index Seek") để tìm kết quả siêu nhanh
SELECT * FROM KHACHHANG
WHERE DienThoai = '0922222222';