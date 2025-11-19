--Thêm khách hàng mới
CREATE PROCEDURE P_ThemKhachHang
@MaKH NVARCHAR(6), @HoTen NVARCHAR(100), @DiaChi NVARCHAR(255), @DienThoai NVARCHAR(10)
AS
BEGIN
INSERT INTO KHACHHANG(MaKH, HoTenKH, DiaChi, DienThoai)
VALUES(@MaKH, @HoTen, @DiaChi, @DienThoai);
END;
GO
EXEC P_ThemKhachHang 'KH999', N'Test Name', N'Địa chỉ test', '0909999999';

--Cập nhật trạng thái đơn hàng
CREATE PROCEDURE P_CapNhat_TrangThai
@MaDH INT, @TrangThai NVARCHAR(50)
AS
BEGIN
UPDATE DONHANG SET TrangThai = @TrangThai WHERE MaDH = @MaDH;
END;
GO
EXEC P_CapNhat_TrangThai 1, N'Hoàn tất';

--Thêm sản phẩm vào chi tiết đơn hàng
CREATE PROCEDURE P_Them_ChiTiet
@MaDH INT, @MaSP NVARCHAR(10), @SoLuong INT, @Gia MONEY
AS
BEGIN
INSERT INTO CHITIETDONHANG(MaDH, MaSP, SoLuong, GiaBan)
VALUES(@MaDH, @MaSP, @SoLuong, @Gia);
END;
GO
EXEC P_Them_ChiTiet 1, 'QA002', 1, 299000;

--Kiểm tra đơn hàng theo mã KH
CREATE PROCEDURE P_TimDonHang_TheoKH
@MaKH NVARCHAR(6)
AS
BEGIN
SELECT * FROM DONHANG WHERE MaKH = @MaKH;
END;
GO
EXEC P_TimDonHang_TheoKH 'KH001';

--Lấy danh sách sản phẩm theo loại
CREATE PROCEDURE P_SanPham_TheoLoai
@MaLoaiSP NVARCHAR(10)
AS
BEGIN
SELECT * FROM SANPHAM WHERE MaLoaiSP = @MaLoaiSP;
END;
GO
EXEC P_SanPham_TheoLoai 'LSP01';
