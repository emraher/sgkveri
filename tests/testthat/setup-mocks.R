# Setup for httptest2 mocks
# This file runs before tests to configure httptest2

# Check if httptest2 is available
has_httptest2 <- function() {
  requireNamespace("httptest2", quietly = TRUE)
}

# Helper to create mock data for testing
mock_categories_data <- function() {
  list(
    list(
      id = "1",
      kategoriAdi = "Aktif Sigortalılar",
      children = list(
        list(
          id = "90",
          label = "01.Toplam Aktif Sigortalı (4a, 4b, 4c)",
          tanim = "İlgili dönemde en az 1 gün hizmet bildirimi yapılan toplam sigortalı sayısını gösterir.",
          birim = "Kisi",
          yayinlanmaSikligi = "Aylik",
          yayinlanmaZamani = "Aylik",
          kaynak = "SGK",
          type = "indicator"
        ),
        list(
          id = "91",
          label = "01.Toplam Aktif Sigortalı (4a, 4b, 4c) - Erkek",
          tanim = "İlgili dönemde en az 1 gün hizmet bildirimi yapılan erkek sigortalı sayısını gösterir.",
          birim = "Kisi",
          yayinlanmaSikligi = "Aylik",
          yayinlanmaZamani = "Aylik",
          kaynak = "SGK",
          type = "indicator"
        )
      )
    )
  )
}

mock_cities_data <- function() {
  list(
    list(id = 77L, plakaKodu = 1L, sehirAdi = "Adana"),
    list(id = 83L, plakaKodu = 34L, sehirAdi = "İstanbul"),
    list(id = 77L, plakaKodu = 6L, sehirAdi = "Ankara"),
    list(id = 79L, plakaKodu = 35L, sehirAdi = "İzmir"),
    list(id = 1L, plakaKodu = 999L, sehirAdi = "Türkiye")
  )
}

mock_years_data <- function() {
  list(
    list(id = 2020L, yil = 2020L),
    list(id = 2021L, yil = 2021L),
    list(id = 2022L, yil = 2022L),
    list(id = 2023L, yil = 2023L),
    list(id = 2024L, yil = 2024L)
  )
}

mock_veri_data <- function() {
  list(
    list(
      sehirAdi = "İstanbul",
      plakaKodu = "34",
      gostergeAdi = "01.Toplam Aktif Sigortalı (4a, 4b, 4c)",
      kategoriAdi = "Aktif Sigortalılar",
      cografiBolgeAdi = "Marmara",
      istatistikiBolgeAdi = "İstanbul",
      birim = "Kisi",
      tutarlar = list(
        "2023" = "5.432.100"
      )
    )
  )
}
