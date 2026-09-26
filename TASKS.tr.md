# Yol Haritası — Olist Analytics Engineering Projesi

[`TASKS.md`](TASKS.md)'nin Türkçe karşılığı. Bölüm ve görev numaraları birebir aynı.

**İlerleme takibi GitHub'da yapılır, bu dosyada değil.** Her görev kendi issue'suna
bağlanıyor; bir görevin bitip bitmediğini o issue'nun durumu belirler, hepsi birden
[Olist dbt Roadmap](https://github.com/users/dogukan-arguc/projects/1) board'unda görünür.
Her faz bir milestone, her sertifika etiketi bir label. Görevi, onu bitiren commit ya da
pull request kapatır (`Closes #17`). Bu dosya içeriğin Türkçesini verir; tamamlanma
durumunu değil.

Teknik terimler bilerek İngilizce bırakıldı — dbt dokümantasyonu ve sertifika sınavı
bu terimleri kullanıyor, onları İngilizce öğrenmek işin bir parçası.

Bu projenin yol haritası. **Her görevi kendin implemente ediyorsun.** Her madde bir hedef
ve bir *tamamlanma ölçütü* veriyor — çözüm vermiyor. İpuçları katlanmış durumda; bir süre
takıldıktan sonra aç. Daha fazlası için Claude'a sor ve hangi seviyede ipucu istediğini
söyle (dürtme → yaklaşım → iskelet → kod).

**Sertifika etiketleri** her görevi bir sınav alanına bağlıyor: `[DEV]` model geliştirme ·
`[DEBUG]` hata ayıklama · `[TEST]` test yazma · `[MONITOR]` pipeline izleme · `[DEPLOY]`
iş dağıtımı · `[STATE]` dbt state · `[GOV]` yönetişim. Sınava girmeden önce alan listesini
güncel resmî çalışma kılavuzuyla karşılaştır — dbt Labs bunu revize ediyor.

**⭐ işaretliler farkı yaratanlar.** Portfolyo dbt projelerinin çoğu faz 3'ten sonra
duruyor. İşe alım yapan birinin durup bakmasını sağlayan şey bunlar.

---

## Faz 0 — Temeller

Hedef: temiz ve sürümleri sabitlenmiş bir ortamda, klonlanıp çalıştırılabilen bir repo.

### 0.1 Ortamı uv ile kur `[DEV]` · [#8](https://github.com/dogukan-arguc/dbt_portfolio/issues/8)

`pyproject.toml` bağımlılıkları tanımlıyor, `.python-version` Python 3.12'yi sabitliyor,
`uv.lock` commit'li. `uv sync` lock dosyasından `.venv/` oluşturuyor ve gerekirse Python'ı
kendisi indiriyor.

*Tamamlanma ölçütü:* `uv run dbt --version` çıktısında dbt-core 1.10.x ve duckdb
adapter'ı görünüyor. ✅ dbt-core 1.10.23, duckdb 1.10.1.

### 0.2 Bağlantıyı doğrula `[DEBUG]` · [#9](https://github.com/dogukan-arguc/dbt_portfolio/issues/9)

`olist_dbt/` içinden `uv run dbt debug` çalıştır. Neden oradan çalıştırılması gerektiğini
anla. ✅ Tüm kontroller geçti.

*Tamamlanma ölçütü:* Tüm kontroller geçiyor ve dbt'nin `profiles.yml`'ı ve DuckDB
dosyasını nasıl bulduğunu tek cümleyle açıklayabiliyorsun.

<details><summary>İpucu</summary>

dbt `profiles.yml`'ı önce bulunduğun dizinde arar, sonra `~/.dbt/` içinde. Dosyadaki
`path:` değeri de aynı dizine göre görelidir.

</details>

### 0.3 Repo düzeni `[DEV]` · [#10](https://github.com/dogukan-arguc/dbt_portfolio/issues/10)

Üst seviye yapıya son halini ver. İki açık konu:

- `load_to_duckdb.py` ve `ui.py` kökte duruyor. `0.4` ve `4.1` görevleri iki script daha
  ekleyecek, o yüzden `scripts/` altına taşınıp taşınmayacaklarına şimdi karar ver —
  taşırsan `README.md` ve `CLAUDE.md` içindeki yolları da güncelle.
- `olist_dbt/README.md` hâlâ dbt'nin ürettiği boilerplate. Kökteki `README.md` artık her
  şeyi kapsıyor; bunu sil ya da değiştir.

*Tamamlanma ölçütü:* Kökte yalnızca yerini hak eden dosyalar var ve hiçbir doküman
taşınmış bir yola atıf yapmıyor.

### 0.4 Veri edinimini tekrarlanabilir yap `[DEV]` · [#11](https://github.com/dogukan-arguc/dbt_portfolio/issues/11)

`archive/` gitignore'da, yani yeni bir klonda veri yok. Kaggle veri setini `archive/`
içine indiren bir `scripts/get_data.py` yaz (ya da manuel adımları dokümante et) ve
`load_to_duckdb.py` ile zincirle.

*Tamamlanma ölçütü:* Kaggle hesabı olan bir yabancı, README'yi takip ederek
`git clone`'dan dolu bir `olist.duckdb`'ye ulaşabiliyor.

<details><summary>İpucu</summary>

`kaggle` CLI'ı (`uv add kaggle`) kimlik bilgilerini `~/.kaggle/kaggle.json` dosyasından
okur. Veri seti slug'ı: `olistbr/brazilian-ecommerce`. Kimlik dosyasının yolunu
README'deki ön koşullara ekle — token'ı asla commit'leme.

</details>

### 0.5 Örneklem veri setini seed olarak commit'le ⭐ `[DEV]` · [#12](https://github.com/dogukan-arguc/dbt_portfolio/issues/12)

CSV'lerin tamamı commit'lenemez (121 MB; tek başına `geolocation` 61 MB). Onun yerine
`olist_dbt/seeds/` altına **referansiyel olarak tutarlı ~%1'lik bir örneklem** commit'le
ki isteyen sıfır kurulumla hemen `dbt build` çalıştırabilsin.

Zor kısmı referansiyel tutarlılık: her tabloyu bağımsız örnekleyemezsin, yoksa join'lerin
boş sonuç döner.

*Tamamlanma ölçütü:* `archive/` klasörü olmayan bir makinede `dbt seed && dbt build`
tamamlanıyor ve mart'larda anlamlı sayıda satır oluyor.

<details><summary>İpucu</summary>

Önce **orders**'ı örnekle, sonra yalnızca o order id'lerine ait alt satırları al, sonra
da yalnızca o alt satırların referans verdiği customer/product/seller kayıtlarını. Foreign
key'ler boyunca **aşağı doğru** örnekle, asla yatay olarak.

</details>

<details><summary>Daha fazla</summary>

DuckDB ile bir `scripts/make_sample.py` yaz: `USING SAMPLE` ile ~1000 order id seç, geçici
bir tabloya yaz, sonra diğer tabloları buna karşı `SEMI JOIN` ile filtrele.
`COPY (...) TO 'seeds/x.csv' (HEADER)` ile dışa aktar. `geolocation`'ı ya atla ya da
yalnızca hayatta kalan zip prefix'lerine göre örnekle.

Sonra modellerin seed ile `raw` arasında nasıl seçim yapacağına karar ver — source
tanımlarında `target.name` kontrolü ya da `{{ var('use_seeds', false) }}` gibi bir dbt
var'ı.

</details>

### 0.6 Paketleri ekle `[DEV]` · [#13](https://github.com/dogukan-arguc/dbt_portfolio/issues/13)

`dbt_utils`, `dbt_expectations`, `codegen` ve `dbt_date` içeren bir `packages.yml`
oluştur. `uv run dbt deps` çalıştır. `dbt_packages/`'in gitignore'da olduğunu ama
`package-lock.yml`'ın **commit'lendiğini** doğrula — `uv.lock` ile aynı mantık, bir katman
aşağıda.

*Tamamlanma ölçütü:* `dbt deps` başarılı ve her paketin ne işe yaradığını biliyorsun.

<details><summary>İpucu</summary>

`codegen` 1.3'te zaman kazandıracak — `dbt run-operation generate_base_model` bir
source'tan staging modelinin iskeletini senin yerine yazıyor. Bu düşünmek değil iskele
kurmak, o yüzden kullanman serbest.

</details>

---

## Faz 1 — Source'lar ve Staging

Hedef: her raw tablo tanımlanmış, dokümante edilmiş ve temiz biçimde staging'e alınmış
olsun.

### 1.1 Dokuz source'un hepsini tanımla `[DEV]` · [#14](https://github.com/dogukan-arguc/dbt_portfolio/issues/14)

`_olist__sources.yml` şu an sadece `orders`'ı tanımlıyor. Diğer sekizini, her birine
`description:` yazarak ekle. Loader'ın ürettiği isimler: `raw.order_items`,
`raw.order_payments`, `raw.order_reviews`, `raw.customers`, `raw.sellers`, `raw.products`,
`raw.geolocation`, `raw.product_category_name_translation`.

*Tamamlanma ölçütü:* `dbt ls --select source:olist` dokuz source listeliyor.

### 1.2 Source freshness `[MONITOR]` · [#15](https://github.com/dogukan-arguc/dbt_portfolio/issues/15)

`orders`'a `loaded_at_field` ve `freshness` eşikleri ekle. Veri 2018'den kalma statik bir
döküm olduğu için freshness gürültülü şekilde başarısız olacak — asıl ders bu. Nasıl ele
alacağına karar ver: geniş bir eşik, `filter:` kullanımı, ya da freshness'ı kapatıp
nedenini yazan açık bir yorum.

*Tamamlanma ölçütü:* `dbt source freshness` çalışıyor ve sonucu kaza değil, savunabildiğin
bilinçli bir tercih.

### 1.3 Staging katmanını kur `[DEV]` · [#16](https://github.com/dogukan-arguc/dbt_portfolio/issues/16)

Her source için bir `stg_olist__<entity>.sql`. snake_case iş isimlerine çevir, tipleri
cast et, string'leri trim'le, büyük/küçük harfi standartlaştır. **Join yok, aggregation
yok, iş mantığı yok.**

Özel iş: `products` kolonlarının isimleri Portekizce ve hatalı yazılmış
(`product_name_lenght` — yazım hatası kaynakta) — burada düzelt. Metin olarak gelen
timestamp'lerin cast edilmesi gerekiyor.

*Tamamlanma ölçütü:* Dokuz staging modeli view olarak build oluyor ve her biri kendi
source'uyla 1:1.

<details><summary>İpucu</summary>

İki CTE'li kalıbı kullan: sadece `select * from {{ source(...) }}` yapan bir `source`
CTE'si, ardından tüm işi yapan bir `renamed` CTE'si. Bu, raw ile staging arasındaki farkı
inceleyen biri için apaçık hale getirir.

</details>

### 1.4 Kategori çevirisini ele al `[DEV]` · [#17](https://github.com/dogukan-arguc/dbt_portfolio/issues/17)

`product_category_name_translation` 2.6 KB'lık statik bir lookup verisi. Bunun source mu
yoksa **seed** mi olması gerektiğini gerekçelendir, sonra kararını uygula.

*Tamamlanma ölçütü:* İngilizce kategori isimleri alt katmanlarda kullanılabiliyor ve
gerekçen README'de ya da model açıklamasında kayıtlı.

### 1.5 Staging katmanını dokümante et `[DEV]` · [#18](https://github.com/dogukan-arguc/dbt_portfolio/issues/18)

Her modele ve her kolona `description:` içeren bir `_staging__models.yml`. Tekrarlanan her
şey için bir `.md` dosyasında `{{ doc(...) }}` blokları kullan (örneğin
`customer_unique_id`'nin ne anlama geldiğini — bunu birden fazla kez açıklayacaksın).

*Tamamlanma ölçütü:* `dbt docs generate` çıktısında staging'de dokümante edilmemiş kolon
kalmıyor.

---

## Faz 2 — Test ve Veri Kalitesi

Hedef: süs olsun diye değil, gerçekten bir regresyonu yakalayacak testler.

### 2.1 Temel generic testler `[TEST]` · [#19](https://github.com/dogukan-arguc/dbt_portfolio/issues/19)

Her primary key'e `unique` + `not_null`, her foreign key'e `relationships`, `order_status`
ve `payment_type`'a `accepted_values`.

Başarısızlık bekle. `order_reviews.review_id` **unique değil** ve bazı
`order_items.product_id` değerleri karşılık bulmayabilir. Başarısız olan testi silme —
önce araştır.

*Tamamlanma ölçütü:* `dbt test` yeşil **ve** gevşettiğin ya da kaldırdığın her testin
yanında ne bulduğunu açıklayan bir yorum var.

### 2.2 Bileşik anahtar testleri `[TEST]` · [#20](https://github.com/dogukan-arguc/dbt_portfolio/issues/20)

`order_items`'ın anahtarı `(order_id, order_item_id)`, `order_payments`'ınki `(order_id,
payment_sequential)`. Tek kolonluk bir `unique` testi bunu ifade edemez.

*Tamamlanma ölçütü:* Her iki grain (kırılım) de test ediliyor.

<details><summary>İpucu</summary>

`dbt_utils.unique_combination_of_columns`. Alternatifi —
`dbt_utils.generate_surrogate_key` ile bir surrogate key üretip onu test etmek — de
geçerli ve alt katmanlarda daha faydalı. İkisini birden yapmayı düşün.

</details>

### 2.3 dbt_expectations testleri `[TEST]` · [#21](https://github.com/dogukan-arguc/dbt_portfolio/issues/21)

Gerçek bir iş kuralını ifade ettikleri yerlerde değer aralığı ve dağılım testleri ekle:
`price > 0`, `review_score` 1 ile 5 arasında, `payment_installments` makul bir sınırda,
mart'larda satır sayısı kontrolü.

*Tamamlanma ölçütü:* En az altı expectation tarzı test var ve her biri açıkça yazılmış bir
kurala karşılık geliyor.

### 2.4 Kendi generic testini yaz `[TEST]` · [#22](https://github.com/dogukan-arguc/dbt_portfolio/issues/22)

`tests/generic/` altında, argüman alan ve YAML'dan uygulanabilen bir test. İyi aday:
`assert_no_future_dates`, ya da dokümante edilmiş bir null oranına izin veren bir pozitif
değer testi.

*Tamamlanma ölçütü:* Test en az iki modelin YAML'ında kullanılıyor.

### 2.5 Gerçek tuzaklar için singular testler ⭐ `[TEST]` · [#23](https://github.com/dogukan-arguc/dbt_portfolio/issues/23)

Veriyi anladığını kanıtlayan testler bunlar:

- **Gelir mutabakatı** — sipariş başına toplam `payment_value` ile kalemlerden gelen
  `sum(price + freight_value)`'ı bir tolerans dahilinde karşılaştır. Fan-out (satır
  çoğalması) hatalarını yakalar.
- **Teslimat mantık kontrolü** — hiçbir `delivered_customer_date`,
  `order_purchase_timestamp`'ten önce olamaz.
- **Fan-out koruması** — `fct_orders` satır sayısı, distinct `order_id` sayısına eşit
  olmalı.

*Tamamlanma ölçütü:* `tests/` altında üç singular test var ve her birinin hangi
production hatasını yakalayacağını açıklayabiliyorsun.

### 2.6 Unit testler ⭐ `[TEST]` · [#24](https://github.com/dogukan-arguc/dbt_portfolio/issues/24)

dbt 1.8+ ile gelen `unit_tests:` — sabit girdi satırları, beklenen çıktı satırları,
warehouse verisine ihtiyaç yok. Portfolyo projelerinin neredeyse hiçbirinde yok. En çok
mantık içeren modeline uygula (payment pivot ya da RFM segmentleme modeli).

*Tamamlanma ölçütü:* `dbt test` altında en az iki unit test çalışıyor ve bunlardan biri
bir uç durumu kapsıyor (bir null, ya da hiç ödemesi olmayan bir sipariş).

<details><summary>İpucu</summary>

Unit testler `tests/` altında değil, modelin YAML'ında yer alır. `ref`/`source` fixture'ları
içeren bir `given:` ve bir `expect:` bloğu isterler.
`dbt test --select test_type:unit` ile çalıştır.

</details>

### 2.7 Test konfigürasyonu `[TEST]` `[MONITOR]` · [#25](https://github.com/dogukan-arguc/dbt_portfolio/issues/25)

Başarısızlığın bilgilendirme amaçlı olduğu yerlerde `severity: warn`, az sayıda hatalı
satırın tolere edilebildiği yerlerde `error_if`/`warn_if` eşikleri, sonradan incelemeye
değer testlerde `store_failures: true` kullan.

*Tamamlanma ölçütü:* Her test ikili (geçti/kaldı) bir hata değil ve başarısızlık tabloları
sorgulanabilir durumda.

---

## Faz 3 — Intermediate ve Mart'lar

Hedef: bir BI aracının ek dönüşüm yapmadan üzerine oturabileceği bir boyutsal
(dimensional) model.

### 3.1 Ödeme fan-out'unu çöz `[DEV]` · [#26](https://github.com/dogukan-arguc/dbt_portfolio/issues/26)

`order_payments` sipariş başına birden fazla satır içeriyor. **Sipariş başına tek satır**
olan bir intermediate model kur; toplam ödenen tutarı, taksit sayısını ve ödeme tipine
göre kırılımı taşısın.

*Tamamlanma ölçütü:* Model `order_id` başına tam olarak bir satır içeriyor ve bunu bir
test kanıtlıyor.

<details><summary>İpucu</summary>

Aggregate ve pivot'u tek geçişte yap — sipariş bazında gruplayıp her tip için
`sum(case when payment_type = 'credit_card' then payment_value end)`. Elle yazmak
istemezsen `dbt_utils.pivot` bunu distinct değerlerden üretebilir.

</details>

### 3.2 Zenginleştirilmiş sipariş kalemleri `[DEV]` · [#27](https://github.com/dogukan-arguc/dbt_portfolio/issues/27)

Kalemleri ürünlerle (İngilizce kategorilerle) ve satıcılarla join'le. Grain sipariş kalemi
seviyesinde kalır.

*Tamamlanma ölçütü:* Satır sayısı `stg_olist__order_items` ile aynı — satır sayısını
değiştiren bir join hatadır.

### 3.3 `dim_customers` ⭐ `[DEV]` · [#28](https://github.com/dogukan-arguc/dbt_portfolio/issues/28)

Bu veri setinin en önemli tuzağı. `customer_id` sipariş başına bir satır; gerçek kişi
`customer_unique_id`. Boyutu **kişi** grain'inde kur; ilk ve son sipariş tarihi, yaşam
boyu sipariş sayısı ve yaşam boyu değer içersin.

*Tamamlanma ölçütü:* Satır sayısı `stg_olist__customers`'tan belirgin şekilde düşük ve
model açıklaması `customer_id` ile `customer_unique_id` farkını anlatıyor.

### 3.4 `dim_products` ve `dim_sellers` `[DEV]` · [#29](https://github.com/dogukan-arguc/dbt_portfolio/issues/29)

İngilizce kategoriler, null kategorilerin açıkça ele alınması (bir `'unknown'` kovası
null'dan iyidir), fiziksel ölçülerin temizlenmesi.

*Tamamlanma ölçütü:* İkisi de kolon seviyesinde tam dokümantasyonla build oluyor.

### 3.5 `dim_geolocation` `[DEV]` · [#30](https://github.com/dogukan-arguc/dbt_portfolio/issues/30)

61 MB, zip prefix başına çok sayıda gürültülü satır, aksanlı ve tutarsız şehir isimleri.
`zip_code_prefix` başına tek satıra indir; temsili bir koordinat ve standart bir şehir
ismi taşısın.

*Tamamlanma ölçütü:* Zip prefix başına bir satır var ve lat/lng için hangi merkezi eğilim
ölçüsünü neden seçtiğini söyleyebiliyorsun.

<details><summary>İpucu</summary>

Ortalama, geocoding aykırı değerleri tarafından sürüklenir; medyan sürüklenmez. Ayrıca
şehir isimlerindeki aksanları kaldırıp kaldırmayacağına ve bunun bilgi kaybı olup
olmadığına karar ver.

</details>

### 3.6 `dim_date` `[DEV]` · [#31](https://github.com/dogukan-arguc/dbt_portfolio/issues/31)

Veri setinin tarih aralığını kapsayan, alışıldık takvim özelliklerini içeren bir date
spine; istersen Brezilya resmî tatillerini de ekle (tatiller e-ticaret hacmini gözle
görülür şekilde etkiliyor — 2017 Black Friday bu veride çok belirgin).

*Tamamlanma ölçütü:* Spine, tüm sipariş tarih aralığı boyunca boşluksuz.

<details><summary>İpucu</summary>

`dbt_utils.date_spine`, ya da hazır bir sürüm için `dbt_date.get_date_dimension`. Kendin
üretmek öğrenme açısından daha iyi bir alıştırma.

</details>

### 3.7 `fct_orders` `[DEV]` · [#32](https://github.com/dogukan-arguc/dbt_portfolio/issues/32)

Sipariş başına tek satır. Her boyuta foreign key'ler, artı ölçütler: kalem sayısı, ürün
geliri, kargo, toplam ödenen, review puanı. Teslimat zaman ölçütlerini de ekle — onay
gecikmesi, teslimat gün sayısı, tahmine göre kaç gün erken/geç, ve bir zamanında-teslimat
bayrağı.

*Tamamlanma ölçütü:* Sipariş başına bir satır, tüm FK'ler `relationships` testlerini
geçiyor ve gelir, faz 2.5'teki testle mutabık.

### 3.8 `fct_order_items` `[DEV]` · [#33](https://github.com/dogukan-arguc/dbt_portfolio/issues/33)

Surrogate key'li sipariş kalemi grain'i. Sipariş seviyesindeki ödeme tutarlarını kalem
seviyesine orantılı olarak dağıt — ve dağıtım kuralını savunabil.

*Tamamlanma ölçütü:* Dağıtılan tutarlar, tolerans dahilinde sipariş toplamına geri
toplanıyor.

### 3.9 Analitik mart'lar ⭐ `[DEV]` · [#34](https://github.com/dogukan-arguc/dbt_portfolio/issues/34)

Burada tesisatçılık değil, analitik muhakeme gösteriyorsun. En az üç tane kur:

- **`mart_customer_rfm`** — recency/frequency/monetary skorlaması ve isimlendirilmiş
  segmentler (Champions, At Risk, Hibernating). Dürüst uyarıyı da not et: Olist
  müşterilerinin çoğu tam olarak bir kez sipariş veriyor, bu da F boyutunu neredeyse
  işlevsiz bırakıyor. Bunu söylemek, gizlemekten daha güçlü.
- **`mart_seller_scorecard`** — satıcı başına: hacim, gelir, ortalama review, zamanında
  teslimat oranı, ortalama kargoya veriliş gecikmesi. Kategori içinde sırala.
- **`mart_delivery_performance`** — eyalete, kategoriye ve aya göre zamanında teslimat
  oranı; teslimat gecikmesi ile review puanı arasındaki ilişki. (Burada güçlü ve gerçek
  bir sinyal var — geç teslimatlar review puanlarını çökertiyor. Manşet grafiğin bu
  olacak.)
- **`mart_cohort_retention`** — aylık kazanım kohortları ve tekrar satın alma oranı.
- **`mart_category_monthly`** — trend grafikleri için kategori × ay kırılımı.

*Tamamlanma ölçütü:* Üç veya daha fazlası mevcut ve her biri hangi soruyu cevapladığıyla
birlikte dokümante edilmiş.

---

## Faz 4 — İleri Materialization'lar ve Yükleme Saati ⭐

Hedef: production kalıplarını yönetebildiğini kanıtlamak; her gece her şeyi baştan kurmak
değil. Bu faz projedeki en büyük tek farklılaştırıcı.

### 4.1 Simüle edilmiş yükleme saati kur ⭐ `[DEV]` · [#35](https://github.com/dogukan-arguc/dbt_portfolio/issues/35)

Sorun: Olist 2018'den kalma statik bir döküm, dolayısıyla incremental modeller ve
snapshot'lar bunun üzerinde anlamsız bir tiyatro. Çözüm: `scripts/simulate_load.py --as-of
YYYY-MM-DD` — `raw`'a yalnızca o tarih itibarıyla var olan kayıtları yükler ve sipariş
statüsünü o günkü haline çevirir (Mart'ta teslim edilmiş bir sipariş, Şubat'ta duruyorsan
hâlâ `shipped`'tir).

Böylece saati gün gün ileri alıp incremental mantığın ve SCD2 geçmişinin gerçekten
çalıştığını görebilirsin.

*Tamamlanma ölçütü:* İki farklı `--as-of` tarihiyle çalıştırmak, statüler dahil gerçekten
farklı `raw.orders` içeriği üretiyor.

<details><summary>İpucu</summary>

Satırları `order_purchase_timestamp <= as_of` ile filtrele. Statü için timestamp
kolonlarını geriye doğru yürü: eğer `delivered_customer_date > as_of` ise sipariş henüz
teslim edilmemiştir — hangi timestamp'lerin geçtiğine bakarak sırasıyla `shipped`,
`approved`, `created`'a düş. Asıl alıştırma bu geriye yürüyüş.

</details>

### 4.2 Incremental `fct_order_items` `[DEV]` `[DEBUG]` · [#36](https://github.com/dogukan-arguc/dbt_portfolio/issues/36)

Modeli `unique_key` ve `is_incremental()` filtresi ile `materialized: incremental`'a
çevir. 4.1'deki saatle düzgün test et: erken bir tarihte full refresh yap, sonra saati
ilerletip incremental çalıştır, sonra geç tarihteki bir full refresh ile karşılaştır.

*Tamamlanma ölçütü:* Incremental çıktı, full refresh çıktısıyla birebir aynı ve
`on_schema_change` seçeneklerini anlamış durumdasın.

### 4.3 Geç gelen veriyi ele al ⭐ `[DEV]` · [#37](https://github.com/dogukan-arguc/dbt_portfolio/issues/37)

Naif bir `where updated_at > (select max(...) from {{ this }})` filtresi, sırasız gelen
kayıtları sessizce düşürür. Bir geriye bakış penceresi (lookback window) ekle ve naif
filtrenin kaybedeceği satırları kurtardığını göster.

*Tamamlanma ölçütü:* Önce hatalı durumu, sonra düzeltmeyi gösterebiliyorsun.

### 4.4 Sipariş statüsünü snapshot'la (SCD2) ⭐ `[DEV]` · [#38](https://github.com/dogukan-arguc/dbt_portfolio/issues/38)

`orders`'ı `order_status` üzerinden `check` stratejisiyle snapshot'la. Saati birkaç tarih
boyunca ilerlet, her seferinde snapshot al ve siparişlerin `created → approved → shipped →
delivered` hareketinin SCD2 geçmişini oluştur.

*Tamamlanma ölçütü:* Snapshot tablosu aynı `order_id` için doğru
`dbt_valid_from` / `dbt_valid_to` değerleriyle birden fazla versiyon tutuyor.

### 4.5 Snapshot üzerine statü süresi modeli kur `[DEV]` · [#39](https://github.com/dogukan-arguc/dbt_portfolio/issues/39)

SCD2 geçmişini kullanarak siparişlerin her statüde ne kadar beklediğini ölç — bu, statik
dökümden hesaplayamayacağın gerçek bir operasyonel metrik. Faz 4'ün getirisi bu.

*Tamamlanma ölçütü:* Statü geçişi başına ortalama süre sorgulanabiliyor.

### 4.6 Ephemeral modeller ve kendi makron `[DEV]` · [#40](https://github.com/dogukan-arguc/dbt_portfolio/issues/40)

Bir model saf tesisatsa `materialized: ephemeral` kullan ve derlenmiş SQL'e bakıp inline
edildiğini gör. Gerçekten yeniden kullanılabilir bir makro yaz (bir `cents_to_currency`
yuvarlayıcı, ya da statü gruplayan bir `case` ifadesi) ve üç veya daha fazla modelde
kullan.

*Tamamlanma ölçütü:* `dbt compile` ephemeral modeli inline gösteriyor ve makro
`macros/_macros.yml` içinde dokümante edilmiş.

---

## Faz 5 — Yönetişim ve Dokümantasyon

Hedef: bir kurs projesini gerçek bir takımdaki projeden ayıran şeyler.

### 5.1 Mart'larda contract ve constraint'ler ⭐ `[GOV]` · [#41](https://github.com/dogukan-arguc/dbt_portfolio/issues/41)

Mart modellerine kolon tipleri ve constraint'ler tanımlanmış şekilde `contract: {enforced:
true}` ekle. Böylece dbt, şekli kaymış bir modeli build etmeyi reddeder.

*Tamamlanma ölçütü:* Kasıtlı bir tip değişikliği build'i contract hatasıyla düşürüyor —
bunu doğrula, sonra geri al. DuckDB'nin yalnızca bazı constraint tiplerini zorladığını
unutma; hangilerinin gerçekten kontrol edildiğini, hangilerinin sadece bilgi amaçlı
olduğunu dokümante et.

### 5.2 Model versiyonlama `[GOV]` · [#42](https://github.com/dogukan-arguc/dbt_portfolio/issues/42)

Bir mart'ı versiyonla (`fct_orders` v1 → v2, aralarında kırıcı bir değişiklikle),
`latest_version` ve v1'de bir `deprecation_date` ile.

*Tamamlanma ölçütü:* İki versiyon da build oluyor ve `ref('fct_orders')` amaçladığın
versiyona çözümleniyor.

### 5.3 Group'lar ve erişim `[GOV]` · [#43](https://github.com/dogukan-arguc/dbt_portfolio/issues/43)

YAML'da sahipleriyle birlikte group'lar tanımla. Staging ve intermediate'e `access:
private`, mart'lara `access: public` ver.

*Tamamlanma ölçütü:* Private bir modele kasıtlı olarak gruplar arası `ref()` yapmak hata
veriyor.

### 5.4 Exposure'lar `[GOV]` `[MONITOR]` · [#44](https://github.com/dogukan-arguc/dbt_portfolio/issues/44)

Evidence dashboard'unu (faz 7) sahibi ve bağımlılıklarıyla birlikte bir exposure olarak
tanımla. Bu, alt akış etkisini DAG'da görünür kılar — `dbt build --select +exposure:...`
anlamlı hale gelir.

*Tamamlanma ölçütü:* Exposure, lineage'iyle birlikte docs sitesinde görünüyor.

### 5.5 Dokümantasyon turu `[GOV]` · [#45](https://github.com/dogukan-arguc/dbt_portfolio/issues/45)

Tekrarlanan her şey için doc block'lar, docs açılış sayfası için özel bir `overview.md`,
ve açıklamaların veritabanı kataloğuna işlenmesi için `persist_docs` açık.

*Tamamlanma ölçütü:* Docs sitesi dbt'nin varsayılanıyla değil, senin yazdığın overview
sayfasıyla açılıyor.

---

## Faz 6 — Dağıtım ve CI/CD ⭐

Hedef: yeşil bir badge ve herkese açık bir docs URL'i. İşe alım yapanların gerçekten
tıkladığı kısım burası.

### 6.1 Pull request'lerde CI ⭐ `[DEPLOY]` · [#46](https://github.com/dogukan-arguc/dbt_portfolio/issues/46)

Her PR'da lock'lanmış ortamı kuran, 0.5'teki örneklem veriyi seed'leyen ve `dbt build`
çalıştıran bir GitHub Actions workflow'u. DuckDB bir dosya olduğu için CI'ın hiçbir
warehouse kimlik bilgisine ihtiyacı yok — bu proje gerçekten ücretsiz ve hızlı bir CI'a
sahip olabilir, ki portfolyo dbt projelerinin çoğu bunu yapamaz.

*Tamamlanma ölçütü:* Bir PR yeşil tik gösteriyor ve kasıtlı olarak bozulmuş bir model onu
kırmızıya çeviriyor.

<details><summary>İpucu</summary>

0.5'in önemi tam olarak burada — commit'lenmiş seed'ler olmadan CI'ın verisi olmaz.

`astral-sh/setup-uv` action'ını `enable-cache: true` ile kullan, sonra
`uv sync --locked`. `--locked` bayrağı, `uv.lock` ile `pyproject.toml` birbirinden
ayrıştıysa CI'ı **düşürür** — istediğin davranış bu, çünkü birinin lock'lamayı unuttuğu
bir bağımlılık değişikliğini yakalar. `dbt_packages/`'i ayrıca cache'le.

</details>

### 6.2 State karşılaştırmalı Slim CI ⭐ `[STATE]` `[DEPLOY]` · [#47](https://github.com/dogukan-arguc/dbt_portfolio/issues/47)

Yalnızca değişeni build et: `dbt build --select state:modified+ --defer --state
./prod-run-artifacts`. Bunun için master dalındaki bir çalıştırmadan `manifest.json`
yayınlaman ve PR job'ında indirmen gerekiyor.

*Tamamlanma ölçütü:* Tek bir staging modeline dokunan bir PR, tüm projeyi değil, o modeli
ve altındakileri build ediyor — ve log bunu kanıtlıyor.

<details><summary>İpucu</summary>

Production `manifest.json`'ını bir GitHub Actions artifact'ı olarak sakla ya da özel bir
dala commit'le. `state:modified` ile `state:new` ve `result:error` arasındaki farkı ve
`--defer`'ın build edilmemiş ref'leri nasıl çözdüğünü anlamak doğrudan sınav konusu.

</details>

### 6.3 Zamanlanmış production çalıştırması `[DEPLOY]` `[MONITOR]` · [#48](https://github.com/dogukan-arguc/dbt_portfolio/issues/48)

Tam build'i çalıştıran, `manifest.json` ve `run_results.json`'ı artifact olarak yükleyen
ve hata durumunda gürültülü şekilde düşen bir `schedule:` workflow'u.

*Tamamlanma ölçütü:* Zamanlanmış çalıştırma en az bir kez, sen başında olmadan başarılı
oldu.

### 6.4 dbt docs'u GitHub Pages'te yayınla ⭐ `[DEPLOY]` · [#49](https://github.com/dogukan-arguc/dbt_portfolio/issues/49)

`dbt docs generate` çalıştır ve `target/` klasörünü GitHub Pages'e dağıt. **Herkese açık,
gezinilebilir bir lineage DAG'ı doğrudan CV'ne koyabileceğin bir link** — inceleyen kişi
hiçbir şey klonlamadan on saniyede tüm model grafiğini görüyor. Bu yol haritasındaki saat
başına en yüksek getirili madde.

*Tamamlanma ölçütü:* Docs sitesi herkese açık bir URL'de canlı ve lineage grafiği
render oluyor.

<details><summary>İpucu</summary>

Üretilen site statik — `index.html` artı `manifest.json` ve `catalog.json`. Faz 7'nin site
kökünü alabilmesi için bunu bir alt yola (`/docs/`) dağıt.

</details>

### 6.5 Pipeline izleme `[MONITOR]` · [#50](https://github.com/dogukan-arguc/dbt_portfolio/issues/50)

Her çalıştırmadan sonra `run_results.json`'ı küçük bir rapora dönüştür: en yavaş modeller,
başarısız testler, toplam süre. İstersen artifact'ları DuckDB'ye geri yükleyip modelle —
dbt'nin kendi metadata'sını modellemesi hoş bir dokunuş.

*Tamamlanma ölçütü:* Başarısız bir çalıştırma, log yığını değil okunabilir bir özet
üretiyor.

---

## Faz 7 — BI Katmanı ⭐

Hedef: canlı bir dashboard URL'i. Streamlit değil **Evidence.dev** — Evidence DuckDB'yi
doğrudan okuyor ve *statik* bir site üretiyor, dolayısıyla GitHub Pages onu sunucusuz ve
ücretsiz barındırıyor. Node v24 zaten kurulu.

### 7.1 Evidence'ı kur `[DEPLOY]` · [#51](https://github.com/dogukan-arguc/dbt_portfolio/issues/51)

`reports/` altında iskeleti oluştur, DuckDB bağlantısını kurulmuş warehouse'a yönlendir,
mart'larını sorguladığını doğrula. Evidence'ın build çıktısını gitignore'a ekle.

*Tamamlanma ölçütü:* `npm run dev`, gerçek bir mart sorgusundan beslenen bir sayfa
render ediyor.

### 7.2 Sayfaları kur · [#52](https://github.com/dogukan-arguc/dbt_portfolio/issues/52)

Dört sayfa; her biri tablo dökmek yerine bir soruyu cevaplasın:

1. **Yönetici özeti** — gelir trendi, sipariş hacmi, sepet ortalaması, review ortalaması.
2. **Teslimat performansı** — eyalete göre zamanında teslimat oranı (harita) ve gecikme
   ile review puanı arasındaki ilişki. En güçlü bulgun bu; onunla başla.
3. **Satıcı karnesi** — aranabilir, sıralanmış ve detaya inilebilen tablo.
4. **Müşteri kohortları** — retention ısı haritası ve RFM segment kırılımı.

*Tamamlanma ölçütü:* Her sayfa bir mart'tan okuyor ve dashboard katmanında hiç iş mantığı
yok. Dönüşüm dbt'ye aittir — projenin bütün tezi bu.

### 7.3 Dashboard'u dağıt ⭐ `[DEPLOY]` · [#53](https://github.com/dogukan-arguc/dbt_portfolio/issues/53)

CI'ı, Evidence'ı build edip GitHub Pages'te site köküne yayınlayacak şekilde genişlet; dbt
docs `/docs/` altında kalsın.

*Tamamlanma ölçütü:* İki herkese açık URL — dashboard ve lineage — ikisi de otomatik
güncelleniyor.

---

## Faz 8 — Portfolyo Cilası

Hedef: projeyi hiç bilmeyen biri değerini doksan saniyede anlasın.

### 8.1 README · [#54](https://github.com/dogukan-arguc/dbt_portfolio/issues/54)

Yapı: tek cümlelik tanıtım → canlı linkler (dashboard, docs) → mimari diyagram → sayılarla
üç ilginç bulgu → en gurur duyduğun modelleme kararları → yerel kurulum. Linkleri kurulum
talimatlarından **önce**, sayfanın üstüne koy.

Mevcut `README.md` bir kurulum kılavuzu. Bu görev onu portfolyo vitrinine çeviriyor —
kurulum içeriğini koru, aşağı taşı.

*Tamamlanma ölçütü:* Hiç dbt kullanmamış biri ne kurduğunu ve neden kurduğunu anlıyor.

### 8.2 Mimari diyagram · [#55](https://github.com/dogukan-arguc/dbt_portfolio/issues/55)

README'de bir Mermaid diyagramı: CSV → DuckDB raw → staging → intermediate → marts →
Evidence, üzerinde CI işaretli. Mermaid GitHub'da doğrudan render oluyor — görsel dosyaya
gerek yok.

### 8.3 İlginç bulgular · [#56](https://github.com/dogukan-arguc/dbt_portfolio/issues/56)

Mart'larından çıkan üç somut, sayısallaştırılmış içgörü. "N günden fazla geç teslim edilen
siparişlerin ortalama review puanı X, zamanında teslim edilenlerin Y" cümlesi, sıralanmış
herhangi bir araç listesinden daha güçlüdür. Sıfat değil, sayı.

### 8.4 CV maddesi · [#57](https://github.com/dogukan-arguc/dbt_portfolio/issues/57)

İki satır, ikisi de linkli: pipeline'ın ne yaptığı ve ölçeği (model sayısı, test sayısı,
satır sayısı), artı kullanılan stack. Kanıtı canlı docs linki taşısın.

### 8.5 Sertifika öz değerlendirmesi · [#58](https://github.com/dogukan-arguc/dbt_portfolio/issues/58)

Aşağıdaki kapsam tablosunu baştan sona geç. İşaretlenmemiş her şey, sınavdan önce kapatman
gereken bir boşluk — ya proje içinde ya da ayrı çalışmayla.

---

## Sertifika kapsamı

Yukarıdaki tablo her sınav alanını onu çalıştıran görevlere bağlıyor.

**En zayıf kapsam: dbt state.** İnsanların en az pratik yaptığı alan, çünkü gerçek bir
deployment olmadan çalıştırılamıyor. Bu projede yalnızca görev 6.2'de karşına çıkacak —
onu atlama.

**Bu projenin kapsamadıkları:** dbt Cloud'a özgü konular (job arayüzü, IDE, ortam
değişkenleri, yalnızca Cloud'da olan zamanlama) ve warehouse'a özgü davranışlar. Bunları
ayrıca çalış — sınav, yerel bir DuckDB projesinin veremeyeceği bir dbt Cloud aşinalığı
varsayıyor.
