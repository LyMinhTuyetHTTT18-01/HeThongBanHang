--Thêm khách hàng mới
CREATE PROCEDURE P_ThemKhachHang
@MaKH NVARCHAR(6), @HoTen NVARCHAR(100), @DiaChi NVARCHAR(255), @DienThoai NVARCHAR(10)
AS
BEGIN
INSERT INTO KHACHHANG(MaKH, HoTenKH, DiaChi, DienThoai)
VALUES(@MaKH, @HoTen, @DiaChi, @DienThoai);
END;
GO

--Cập nhật trạng thái đơn hàng
CREATE PROCEDURE P_CapNhat_TrangThai
@MaDH INT, @TrangThai NVARCHAR(50)
AS
BEGIN
UPDATE DONHANG SET TrangThai = @TrangThai WHERE MaDH = @MaDH;
END;
GO

--Thêm sản phẩm vào chi tiết đơn hàng
CREATE PROCEDURE P_Them_ChiTiet
@MaDH INT, @MaSP NVARCHAR(10), @SoLuong INT, @Gia MONEY
AS
BEGIN
INSERT INTO CHITIETDONHANG(MaDH, MaSP, SoLuong, GiaBan)
VALUES(@MaDH, @MaSP, @SoLuong, @Gia);
END;
GO

--Kiểm tra đơn hàng theo mã KH
CREATE PROCEDURE P_TimDonHang_TheoKH
@MaKH NVARCHAR(6)
AS
BEGIN
SELECT * FROM DONHANG WHERE MaKH = @MaKH;
END;
GO

--Lấy danh sách sản phẩm theo loại
CREATE PROCEDURE P_SanPham_TheoLoai
@MaLoaiSP NVARCHAR(10)
AS
BEGIN
SELECT * FROM SANPHAM WHERE MaLoaiSP = @MaLoaiSP;
END;
GO