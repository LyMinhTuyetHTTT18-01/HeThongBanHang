USE master;
GO
IF exists(Select * from sysdatabases where name='QLHeThongBanHang')
	DROP DATABASE QLHeThongBanHang;
GO
CREATE DATABASE QLHeThongBanHang;

USE QLHeThongBanHang;
GO

-- 1. Bảng NHÂN VIÊN
CREATE TABLE NHANVIEN (
    MaNV NVARCHAR(6) NOT NULL,
    HoTenNV NVARCHAR(100),
    GioiTinh NVARCHAR(10),
    NgaySinh DATE,
    DiaChi NVARCHAR(100), 
    DienThoai NVARCHAR(10),
    ViTriCongViec NVARCHAR(100),
    PRIMARY KEY (MaNV)
);
GO

-- 2. Bảng KHÁCH HÀNG
CREATE TABLE KHACHHANG (  
    MaKH NVARCHAR(6) NOT NULL,  
    HoTenKH NVARCHAR(100),  
    DiaChi NVARCHAR(255),  
    DienThoai NVARCHAR(10),  
    PRIMARY KEY (MaKH)  
);
GO

--3. Bảng LOẠI SẢN PHẨM
CREATE TABLE LOAISANPHAM (
	MaLoaiSP NVARCHAR(10) NOT NULL,
	TenLoaiSP NVARCHAR(100) NOT NULL,
	MoTa NVARCHAR(255),
	PRIMARY KEY (MaLoaiSP)
);
GO

-- 4. Bảng NHÀ CUNG CẤP
CREATE TABLE NHACUNGCAP (
	MaNCC NVARCHAR(10) NOT NULL,
	TenNCC NVARCHAR(100) NOT NULL,
	DiaChi NVARCHAR(255),
	PRIMARY KEY (MaNCC)
);
GO

-- 5. Bảng SẢN PHẨM
CREATE TABLE SANPHAM (
    MaSP NVARCHAR(10) NOT NULL,
    TenSP NVARCHAR(200),
    DonGia MONEY CHECK (DonGia > 0),
    SoLuongTonKho INT CHECK (SoLuongTonKho >= 0),
	MaLoaiSP NVARCHAR(10), 
	MaNCC NVARCHAR(10), 
    PRIMARY KEY (MaSP),
	FOREIGN KEY (MaLoaiSP) REFERENCES LOAISANPHAM(MaLoaiSP),
	FOREIGN KEY (MaNCC) REFERENCES NHACUNGCAP(MaNCC)
);
GO

-- 6. Bảng ĐƠN HÀNG
CREATE TABLE DONHANG (
	MaDH INT IDENTITY(1,1) NOT NULL,
    MaKH NVARCHAR(6), 
    MaNV NVARCHAR(6), 
    NgayDat DATETIME DEFAULT GETDATE(),
    TrangThai NVARCHAR(50)
    PRIMARY KEY (MaDH),
    FOREIGN KEY (MaKH) REFERENCES KHACHHANG(MaKH),
    FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV)
);
GO

-- 7. Bảng CHI TIẾT ĐƠN HÀNG
CREATE TABLE CHITIETDONHANG (
    MaChiTiet INT IDENTITY(1,1) NOT NULL, 
    MaDH INT,
    MaSP NVARCHAR(10),
    SoLuong INT CHECK (SoLuong > 0),
    GiaBan MONEY NOT NULL, 
    PRIMARY KEY (MaChiTiet),
    FOREIGN KEY (MaDH) REFERENCES DONHANG(MaDH),
    FOREIGN KEY (MaSP) REFERENCES SANPHAM(MaSP) 
);
GO

---Chèn dữ liệu bảng---
-- 1. Chèn dữ liệu cho bảng NHÂN VIÊN 
INSERT INTO NHANVIEN (MaNV, HoTenNV, GioiTinh, NgaySinh, DiaChi, DienThoai, ViTriCongViec)
VALUES
	('NV001', N'Nguyễn Văn An', N'Nam', '1990-01-15', N'123 Hà Nội', '0912345678', N'Quản lý cửa hàng'),
	('NV002', N'Trần Thị Bình', N'Nữ', '1995-05-20', N'456 TP. HCM', '0987654321', N'Nhân viên bán hàng'),
	('NV003', N'Lê Văn Cường', N'Nam', '1998-11-01', N'789 Đà Nẵng', '0905111222', N'Nhân viên kho'),
	('NV004', N'Phạm Thị Dung', N'Nữ', '1992-07-30', N'101 Hải Phòng', '0934567890', N'Kế toán');
GO

-- 2. Chèn dữ liệu cho bảng KHÁCH HÀNG
INSERT INTO KHACHHANG (MaKH, HoTenKH, DiaChi, DienThoai)
VALUES
	('KH001', N'Lê Duy An', N'11 Cầu Giấy, Hà Nội', '0911111111'),
	('KH002', N'Nguyễn Mạnh Chiến', N'22 Hai Bà Trưng, Hà Nội', '0922222222'),
	('KH003', N'Nguyễn Việt Công', N'33 Đống Đa, TP. HCM', '0933333333'),
	('KH004', N'Trần Huy Dũng', N'44 Lê Lợi, Đà Nẵng', '0944444444'),
	('KH005', N'Nguyễn Bạch Dương', N'55 Tân Bình, TP. HCM', '0955555555'),
	('KH006', N'Vũ Đức Hưng', N'66 Sơn Trà, Đà Nẵng', '0966666666'),
	('KH007', N'Nguyễn Đức Huy', N'77 Ba Đình, Hà Nội', '0977777777'),
	('KH008', N'Tạ Ánh My', N'88 Hoàng Kiếm, Hà Nội', '0988888888'),
	('KH009', N'Nguyễn Thế Phương Nam', N'99 Quận 1, TP. HCM', '0999999999'),
	('KH010', N'Lý Minh Tuyết', N'101 An Dương, Hải Phòng', '0901010101'),
	('KH011', N'Nguyễn Anh Thư', N'112 Võ Thị Sáu, Cần Thơ', '0902020202'),
	('KH012', N'Nguyễn Thi Thảo Vân', N'123 Nguyễn Văn Cừ, TP. HCM', '0903030303'),
	('KH013', N'Đỗ Duy Văn', N'134 Trần Phú, Hà Nội', '0904040404');
GO

-- 3. Chèn dữ liệu cho bảng LOẠI SẢN PHẨM (MỚI)
INSERT INTO LOAISANPHAM (MaLoaiSP, TenLoaiSP, MoTa)
VALUES
	('LSP01', N'Quần áo', N'Bao gồm áo, quần, váy các loại'),
	('LSP02', N'Giày dép', N'Bao gồm giày thể thao, giày cao gót, dép'),
	('LSP03', N'Túi xách', N'Bao gồm balo, túi xách da, túi tote');
GO

-- 4. Chèn dữ liệu cho bảng NHÀ CUNG CẤP (MỚI)
INSERT INTO NHACUNGCAP (MaNCC, TenNCC, DiaChi)
VALUES
	('NCC01', N'Công ty May An Phước', N'100 An Dương Vương, Q5, TP.HCM'),
	('NCC02', N'Tập đoàn H&M Việt Nam', N'Tầng 2, Vincom Center, Q1, TP.HCM'),
	('NCC03', N'Levi Strauss & Co. Việt Nam', N'150 Nguyễn Trãi, Q1, TP.HCM'),
	('NCC04', N'Inditex (ZARA) Việt Nam', N'Tầng 1, Vincom Center, Q1, TP.HCM'),
	('NCC05', N'Fast Retailing (Uniqlo) Việt Nam', N'Tầng 1, Parkson Lê Thánh Tôn, Q1, TP.HCM'),
	('NCC06', N'Nike Việt Nam', N'Tầng 3, Diamond Plaza, Q1, TP.HCM'),
	('NCC07', N'Adidas Việt Nam', N'Tầng 2, Bitexco, Q1, TP.HCM'),
	('NCC08', N'Công ty Vascara', N'189 Cống Quỳnh, Q1, TP.HCM'),
	('NCC09', N'Bita''s (Biti''s)', N'22 Lý Chiêu Hoàng, Q6, TP.HCM'),
	('NCC10', N'Charles & Keith Việt Nam', N'Tầng 1, Saigon Centre, Q1, TP.HCM'),
	('NCC11', N'Samsonite Việt Nam', N'123 Lê Lợi, Q1, TP.HCM'),
	('NCC12', N'Xưởng may Túi Vải Sài Gòn', N'45/1 Đường số 1, Bình Tân, TP.HCM');
GO

-- 5. Chèn dữ liệu cho bảng SẢN PHẨM
INSERT INTO SANPHAM (MaSP, TenSP, DonGia, SoLuongTonKho, MaLoaiSP, MaNCC)
VALUES
-- Quần áo (LSP01)
	('QA001', N'Áo sơ mi nam An Phước', 850000, 150, 'LSP01', 'NCC01'),
	('QA002', N'Áo phông nữ Cotton H&M', 299000, 300, 'LSP01', 'NCC02'),
	('QA003', N'Quần Jean nam Levi 501', 1750000, 100, 'LSP01', 'NCC03'),
	('QA004', N'Váy liền thân nữ ZARA', 1290000, 80, 'LSP01', 'NCC04'),
	('QA005', N'Áo khoác gió Uniqlo', 999000, 200, 'LSP01', 'NCC05'),
-- Giày dép (LSP02)
	('GD001', N'Giày thể thao Nike Air Force 1', 2800000, 70, 'LSP02', 'NCC06'),
	('GD002', N'Giày chạy bộ Adidas Ultraboost', 4500000, 50, 'LSP02', 'NCC07'),
	('GD003', N'Giày cao gót nữ Vascara', 750000, 120, 'LSP02', 'NCC08'),
	('GD004', N'Dép quai ngang nam Bitis', 250000, 250, 'LSP02', 'NCC09'),
-- Túi xách (LSP03)
	('TX001', N'Túi xách da nữ Charles & Keith', 1850000, 60, 'LSP03', 'NCC10'),
	('TX002', N'Balo laptop nam Samsonite', 2500000, 40, 'LSP03', 'NCC11'),
	('TX003', N'Túi tote vải Canvas', 150000, 400, 'LSP03', 'NCC12');
GO

-- 6. Chèn dữ liệu cho bảng ĐƠN HÀNG
INSERT INTO DONHANG (MaKH, MaNV, NgayDat, TrangThai)
VALUES
	('KH001', 'NV002', '2025-11-01 10:00:00', N'Đã giao hàng'),
	('KH008', 'NV002', '2025-11-02 11:30:00', N'Đã giao hàng'),
	('KH003', 'NV002', '2025-11-03 14:00:00', N'Đang xử lý'),
	('KH005', 'NV004', '2025-11-04 09:15:00', N'Đang giao hàng'),
	('KH011', 'NV002', '2025-11-05 16:45:00', N'Đã giao hàng'),
	('KH002', 'NV001', '2025-11-06 08:00:00', N'Đã hủy'),
	('KH009', 'NV003', '2025-11-07 13:20:00', N'Đang xử lý'),
	('KH004', 'NV004', '2025-11-08 10:10:00', N'Chờ thanh toán');
GO

-- 7. Chèn dữ liệu cho bảng CHI TIẾT ĐƠN HÀNG 
INSERT INTO CHITIETDONHANG (MaDH, MaSP, SoLuong, GiaBan)
VALUES
-- Đơn hàng 1 (MaDH = 1)
(1, 'QA001', 1, 850000), 
(1, 'QA003', 1, 1750000),

-- Đơn hàng 2 (MaDH = 2)
(2, 'QA002', 2, 299000),
(2, 'TX003', 1, 150000),

-- Đơn hàng 3 (MaDH = 3)
(3, 'GD001', 1, 2800000),

-- Đơn hàng 4 (MaDH = 4)
(4, 'QA004', 1, 1290000),
(4, 'TX001', 1, 1850000),
(4, 'GD003', 1, 750000),

-- Đơn hàng 5 (MaDH = 5)
(5, 'TX002', 1, 2500000),

-- Đơn hàng 6 (MaDH = 6) 
(6, 'GD002', 1, 4500000),

-- Đơn hàng 7 (MaDH = 7)
(7, 'QA005', 2, 999000),
(7, 'GD004', 1, 250000),

-- Đơn hàng 8 (MaDH = 8)
(8, 'TX003', 1, 150000);
GO
