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

--Danh sách khách hàng và tổng số đơn họ đã đặt:
CREATE VIEW V_KhachHang_SoDon AS
SELECT KH.MaKH, KH.HoTenKH, COUNT(DH.MaDH) AS SoDon
FROM KHACHHANG KH
LEFT JOIN DONHANG DH ON KH.MaKH = DH.MaKH
GROUP BY KH.MaKH, KH.HoTenKH;
GO
SELECT * FROM V_KhachHang_SoDon;

--Tổng doanh thu theo đơn hàng
CREATE VIEW V_DoanhThu_TheoDon AS
SELECT MaDH, SUM(SoLuong * GiaBan) AS TongTien
FROM CHITIETDONHANG
GROUP BY MaDH;
GO
SELECT * FROM V_DoanhThu_TheoDon;

