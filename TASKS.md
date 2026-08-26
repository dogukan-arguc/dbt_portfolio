# Roadmap — Olist Analytics Engineering Project

The build plan for this project. **You implement every task yourself.** Each task states a goal and a *definition of done* — not a solution. Hints are collapsed; open one only after you've been stuck for a while. For deeper help, ask Claude and say what hint level you want (nudge → approach → skeleton → code).

Every task also carries a collapsed **🇹🇷 Türkçe** block with the same content in Turkish, including its own hint. Technical terms are deliberately left in English — the dbt docs and the certification exam use them, so learning them in English is part of the work.

**Cert tags** map each task to a dbt Analytics Engineering Certification exam domain: `[DEV]` developing models · `[DEBUG]` debugging · `[TEST]` testing · `[MONITOR]`monitoring · `[DEPLOY]` deploying jobs · `[STATE]` dbt state · `[GOV]` governance. Verify the domain list against the current official study guide before you sit the exam — dbt Labs revises it.

**Marked ⭐ = the differentiators.** Most portfolio dbt projects stop after phase 3. These are what make a hiring manager stop scrolling.

<details>
<summary>🇹🇷 Türkçe</summary>

Bu projenin yol haritası. Her görevi kendin implemente ediyorsun. Her madde bir hedef ve bir tamamlanma ölçütü veriyor — çözüm vermiyor. İpuçları katlanmış durumda; bir süre takıldıktan sonra aç. Daha fazlası için Claude'a sor ve hangi seviyede ipucu istediğini söyle (dürtme → yaklaşım → iskelet → kod).Sertifika etiketleri her görevi bir sınav alanına bağlıyor: [DEV] model geliştirme · [DEBUG] hata ayıklama · [TEST] test yazma · [MONITOR] pipeline izleme · [DEPLOY]iş dağıtımı · [STATE] dbt state · [GOV] yönetişim. Sınava girmeden önce alan listesini güncel resmî çalışma kılavuzuyla karşılaştır — dbt Labs bunu revize ediyor.⭐ işaretliler farkı yaratanlar. Portfolyo dbt projelerinin çoğu faz 3'ten sonra duruyor. İşe alım yapan birinin durup bakmasını sağlayan şey bunlar.

</details>

---

## Phase 0 — Foundations

Goal: a clone-and-run repo on a clean, pinned environment.

<details>
<summary>🇹🇷 Türkçe</summary>

Faz 0 — Temeller. Hedef: temiz ve sürümleri sabitlenmiş bir ortamda, klonlanıp çalıştırılabilen bir repo.

</details>

- [x] **0.1 Set up the environment with uv** `[DEV]`

  `pyproject.toml` declares the dependencies, `.python-version` pins Python 3.12, and `uv.lock` is committed. `uv sync` builds `.venv/` from the lock, fetching the interpreter if needed.

  *Done when:* `uv run dbt --version` reports dbt-core 1.10.x with the duckdb adapter listed. ✅ dbt-core 1.10.23, duckdb 1.10.1.

  <details>
<summary>🇹🇷 Türkçe</summary>

0.1 Ortamı uv ile kur — pyproject.toml bağımlılıkları tanımlıyor, .python-version Python 3.12'yi sabitliyor, uv.lock commit'li. uv sync lock dosyasından .venv/ oluşturuyor ve gerekirse Python'ı kendisi indiriyor.Tamamlanma ölçütü: uv run dbt --version çıktısında dbt-core 1.10.x ve duckdb adapter'ı görünüyor. ✅ dbt-core 1.10.23, duckdb 1.10.1.

</details>
  

- [x] **0.2 Verify the connection** `[DEBUG]`

  Run `uv run dbt debug` from inside `olist_dbt/`. Understand *why* it must be run from there. ✅ All checks passed.

  *Done when:* all checks pass, and you can explain in one sentence how dbt located `profiles.yml` and the DuckDB file.

  <details>
<summary>🇹🇷 Türkçe</summary>

0.2 Bağlantıyı doğrula — olist_dbt/ içinden uv run dbt debug çalıştır. Neden oradan çalıştırılması gerektiğini anla. ✅ Tüm kontroller geçti.Tamamlanma ölçütü: Tüm kontroller geçiyor ve dbt'nin profiles.yml'ı ve DuckDB dosyasını nasıl bulduğunu tek cümleyle açıklayabiliyorsun.dbt profiles.yml'ı önce bulunduğun dizinde arar, sonra ~/.dbt/ içinde. Dosyadaki path: değeri de aynı dizine göre görelidir.

</details>
  
  <details>
<summary>Hint</summary>

dbt looks for profiles.yml in the current directory before ~/.dbt/. The path: in it is relative to that same directory.

</details>
  

- [x] **0.3 Repo hygiene** `[DEV]`

  Decide the final top-level structure. Two open items:

  - `load_to_duckdb.py` and `ui.py` sit at the root. Tasks `0.4` and `4.1` add two more scripts, so decide now whether they move into `scripts/` — and update `README.md` and `CLAUDE.md` paths if they do.
  - `olist_dbt/README.md` is still dbt's generated boilerplate. The root `README.md`covers everything now, so delete or replace it.

  *Done when:* the root holds only files that earn their place, and no doc references a path that moved.

  <details>
<summary>🇹🇷 Türkçe</summary>

0.3 Repo düzeni — Üst seviye yapıya son halini ver. İki açık konu:load_to_duckdb.py ve ui.py kökte duruyor. 0.4 ve 4.1 görevleri iki script daha ekleyecek, o yüzden scripts/ altına taşınıp taşınmayacaklarına şimdi karar ver — taşırsan README.md ve CLAUDE.md içindeki yolları da güncelle.olist_dbt/README.md hâlâ dbt'nin ürettiği boilerplate. Kökteki README.md artık her şeyi kapsıyor; bunu sil ya da değiştir.Tamamlanma ölçütü: Kökte yalnızca yerini hak eden dosyalar var ve hiçbir doküman taşınmış bir yola atıf yapmıyor.

</details>
  

- [x] **0.4 Make data acquisition reproducible** `[DEV]`

  `archive/` is gitignored, so a fresh clone has no data. Write `scripts/get_data.py`(or document the manual steps) that pulls the Kaggle dataset into `archive/`, then chain it with `load_to_duckdb.py`.

  *Done when:* a stranger with a Kaggle account can go from `git clone` to a populated `olist.duckdb` by following the README.

  <details>
<summary>🇹🇷 Türkçe</summary>

0.4 Veri edinimini tekrarlanabilir yap — archive/ gitignore'da, yani yeni bir klonda veri yok. Kaggle veri setini archive/ içine indiren bir scripts/get_data.pyyaz (ya da manuel adımları dokümante et) ve load_to_duckdb.py ile zincirle.Tamamlanma ölçütü: Kaggle hesabı olan bir yabancı, README'yi takip ederek git clone'dan dolu bir olist.duckdb'ye ulaşabiliyor.kaggle CLI'ı (uv add kaggle) kimlik bilgilerini ~/.kaggle/kaggle.json dosyasından okur. Veri seti slug'ı: olistbr/brazilian-ecommerce. Kimlik dosyasının yolunu README'deki ön koşullara ekle — token'ı asla commit'leme.

</details>
  
  <details>
<summary>Hint</summary>

The kaggle CLI (uv add kaggle) reads credentials from ~/.kaggle/kaggle.json. The dataset slug is olistbr/brazilian-ecommerce. Add the credential path to the README prerequisites — never commit the token.

</details>
  

- [x] **0.5 Commit a sample dataset as seeds** ⭐ `[DEV]`

  The full CSVs can't be committed (121 MB, `geolocation` alone is 61 MB). Instead commit a **referentially consistent \~1% sample** under `olist_dbt/seeds/` so anyone can `dbt build` immediately with zero setup.

  Referentially consistent is the hard part: you can't sample each table independently or your joins will produce empty results.

  *Done when:* on a machine with no `archive/` folder, `dbt seed && dbt build` completes and marts contain non-trivial rows.

  <details>
<summary>🇹🇷 Türkçe</summary>

0.5 Örneklem veri setini seed olarak commit'le ⭐ — CSV'lerin tamamı commit'lenemez (121 MB; tek başına geolocation 61 MB). Onun yerine olist_dbt/seeds/ altına referansiyel olarak tutarlı ~%1'lik bir örneklem commit'le ki isteyen sıfır kurulumla hemen dbt build çalıştırabilsin.Zor kısmı referansiyel tutarlılık: her tabloyu bağımsız örnekleyemezsin, yoksa join'lerin boş sonuç döner.Tamamlanma ölçütü: archive/ klasörü olmayan bir makinede dbt seed && dbt buildtamamlanıyor ve mart'larda anlamlı sayıda satır oluyor.Önce orders'ı örnekle, sonra yalnızca o order id'lerine ait alt satırları al, sonra da yalnızca o alt satırların referans verdiği customer/product/seller kayıtlarını. Foreign key'ler boyunca aşağı doğru örnekle, asla yatay olarak.DuckDB ile bir scripts/make_sample.py yaz: USING SAMPLE ile ~1000 order id seç, geçici bir tabloya yaz, sonra diğer tabloları buna karşı SEMI JOIN ile filtrele. COPY (...) TO 'seeds/x.csv' (HEADER) ile dışa aktar. geolocation'ı ya atla ya da yalnızca hayatta kalan zip prefix'lerine göre örnekle.Sonra modellerin seed ile raw arasında nasıl seçim yapacağına karar ver — source tanımlarında target.name kontrolü ya da {{ var('use_seeds', false) }} gibi bir dbt var'ı.

</details>
  
  <details>
<summary>Hint</summary>

Sample orders first, then take only the child rows belonging to those order ids, and only the customers/products/sellers referenced by those children. Sample downward through the foreign keys, never sideways.Write scripts/make_sample.py using DuckDB: pick ~1000 order ids with USING SAMPLE, materialize them into a temp table, then SEMI JOIN every other table against it. Export with COPY (...) TO 'seeds/x.csv' (HEADER). Skip geolocation or sample it by the zip prefixes that actually survive.Then decide how models select between seeds and raw — a target.name check or a dbt var like {{ var('use_seeds', false) }} in your source definitions.

</details>
  

- [x] **0.6 Add packages** `[DEV]`

  Create `packages.yml` with `dbt_utils`, `dbt_expectations`, `codegen`, and `dbt_date`. Run `uv run dbt deps`. Confirm `dbt_packages/` is gitignored but `package-lock.yml` is **committed** — the same reasoning as `uv.lock`, one layer down.

  *Done when:* `dbt deps` succeeds and you know what each package is for.

  <details>
<summary>🇹🇷 Türkçe</summary>

0.6 Paketleri ekle — dbt_utils, dbt_expectations, codegen ve dbt_date içeren bir packages.yml oluştur. uv run dbt deps çalıştır. dbt_packages/'in gitignore'da olduğunu ama package-lock.yml'ın commit'lendiğini doğrula — uv.lock ile aynı mantık, bir katman aşağıda.Tamamlanma ölçütü: dbt deps başarılı ve her paketin ne işe yaradığını biliyorsun.codegen 1.3'te zaman kazandıracak — dbt run-operation generate_base_model bir source'tan staging modelinin iskeletini senin yerine yazıyor. Bu düşünmek değil iskele kurmak, o yüzden kullanman serbest.

</details>
  
  <details>
<summary>Hint</summary>

codegen is a time saver you'll use in 1.3 — dbt run-operation generate_base_modelwrites a staging model's boilerplate for you from a source. That's scaffolding, not the thinking, so using it is fair game.

</details>
  

---

## Phase 1 — Sources & Staging

Goal: every raw table declared, documented, and cleanly staged.

<details>
<summary>🇹🇷 Türkçe</summary>

Faz 1 — Source'lar ve Staging. Hedef: her raw tablo tanımlanmış, dokümante edilmiş ve temiz biçimde staging'e alınmış olsun.

</details>

- [x] **1.1 Declare all nine sources** `[DEV]`

  `_olist__sources.yml` currently declares only `orders`. Add the other eight with a `description:` each. Loader naming: `raw.order_items`, `raw.order_payments`, `raw.order_reviews`, `raw.customers`, `raw.sellers`, `raw.products`, `raw.geolocation`, `raw.product_category_name_translation`.

  *Done when:* `dbt ls --select source:olist` lists nine sources.

  <details>
<summary>🇹🇷 Türkçe</summary>

1.1 Dokuz source'un hepsini tanımla — _olist__sources.yml şu an sadece orders'ı tanımlıyor. Diğer sekizini, her birine description: yazarak ekle. Loader'ın ürettiği isimler: raw.order_items, raw.order_payments, raw.order_reviews, raw.customers, raw.sellers, raw.products, raw.geolocation, raw.product_category_name_translation.Tamamlanma ölçütü: dbt ls --select source:olist dokuz source listeliyor.

</details>
  

- [x] **1.2 Source freshness** `[MONITOR]`

  Add `loaded_at_field` and `freshness` thresholds to `orders`. The data is a static 2018 dump, so freshness will fail loudly — that's the lesson. Decide how to handle it: a generous threshold, `filter:`, or an explicit note that freshness is disabled with a comment saying why.

  *Done when:* `dbt source freshness` runs and its result is a deliberate outcome you can justify, not an accident.

  <details>
<summary>🇹🇷 Türkçe</summary>

1.2 Source freshness — orders'a loaded_at_field ve freshness eşikleri ekle. Veri 2018'den kalma statik bir döküm olduğu için freshness gürültülü şekilde başarısız olacak — asıl ders bu. Nasıl ele alacağına karar ver: geniş bir eşik, filter: kullanımı, ya da freshness'ı kapatıp nedenini yazan açık bir yorum.Tamamlanma ölçütü: dbt source freshness çalışıyor ve sonucu kaza değil, savunabildiğin bilinçli bir tercih.

</details>
  

- [x] **1.3 Build the staging layer** `[DEV]`

  One `stg_olist__<entity>.sql` per source. Rename to snake_case business names, cast types, trim strings, standardize casing. **No joins, no aggregation, no business logic.**

  Specific work: `products` columns have Portuguese/misspelled names (`product_name_lenght` — the typo is in the source) — fix them here. Timestamps arriving as text need casting.

  *Done when:* nine staging models build as views and each is 1:1 with its source.

  <details>
<summary>🇹🇷 Türkçe</summary>

1.3 Staging katmanını kur — Her source için bir stg_olist__<entity>.sql. snake_case iş isimlerine çevir, tipleri cast et, string'leri trim'le, büyük/küçük harfi standartlaştır. Join yok, aggregation yok, iş mantığı yok.Özel iş: products kolonlarının isimleri Portekizce ve hatalı yazılmış (product_name_lenght — yazım hatası kaynakta) — burada düzelt. Metin olarak gelen timestamp'lerin cast edilmesi gerekiyor.Tamamlanma ölçütü: Dokuz staging modeli view olarak build oluyor ve her biri kendi source'uyla 1:1.İki CTE'li kalıbı kullan: sadece select * from {{ source(...) }} yapan bir sourceCTE'si, ardından tüm işi yapan bir renamed CTE'si. Bu, raw ile staging arasındaki farkı inceleyen biri için apaçık hale getirir.

</details>
  
  <details>
<summary>Hint</summary>

Use the two-CTE pattern: a source CTE that does nothing but select * from {{ source(...) }}, then a renamed CTE doing all the work. It makes the diff between raw and staged obvious to a reviewer.

</details>
  

- [ ] **1.4 Handle the category translation** `[DEV]`

  `product_category_name_translation` is 2.6 KB of static lookup data. Argue whether it belongs as a source or as a **seed**, then implement your choice.

  *Done when:* English category names are available downstream and your README or model description records the reasoning.

  <details>
<summary>🇹🇷 Türkçe</summary>

1.4 Kategori çevirisini ele al — product_category_name_translation 2.6 KB'lık statik bir lookup verisi. Bunun source mu yoksa seed mi olması gerektiğini gerekçelendir, sonra kararını uygula.Tamamlanma ölçütü: İngilizce kategori isimleri alt katmanlarda kullanılabiliyor ve gerekçen README'de ya da model açıklamasında kayıtlı.

</details>
  

- [ ] **1.5 Document the staging layer** `[DEV]`

  `_staging__models.yml` with a `description:` on every model and every column. Use `{{ doc(...) }}` blocks in a `.md` file for anything you repeat (e.g. what `customer_unique_id` means — you'll explain it more than once).

  *Done when:* `dbt docs generate` shows no undocumented columns in staging.

  <details>
<summary>🇹🇷 Türkçe</summary>

1.5 Staging katmanını dokümante et — Her modele ve her kolona description: içeren bir _staging__models.yml. Tekrarlanan her şey için bir .md dosyasında {{ doc(...) }} blokları kullan (örneğin customer_unique_id'nin ne anlama geldiğini — bunu birden fazla kez açıklayacaksın).Tamamlanma ölçütü: dbt docs generate çıktısında staging'de dokümante edilmemiş kolon kalmıyor.

</details>
  

---

## Phase 2 — Testing & Data Quality

Goal: tests that would actually catch a regression, not decoration.

<details>
<summary>🇹🇷 Türkçe</summary>

Faz 2 — Test ve Veri Kalitesi. Hedef: süs olsun diye değil, gerçekten bir regresyonu yakalayacak testler.

</details>

- [ ] **2.1 Baseline generic tests** `[TEST]`

  `unique` + `not_null` on every primary key, `relationships` on every foreign key, `accepted_values` on `order_status` and `payment_type`.

  Expect failures. `order_reviews.review_id` is **not unique**, and some `order_items.product_id` values may not resolve. Do not delete the failing test — investigate first.

  *Done when:* `dbt test` is green *and* every test you weakened or removed has a comment explaining what you found.

  <details>
<summary>🇹🇷 Türkçe</summary>

2.1 Temel generic testler — Her primary key'e unique + not_null, her foreign key'e relationships, order_status ve payment_type'a accepted_values.Başarısızlık bekle. order_reviews.review_id unique değil ve bazı order_items.product_id değerleri karşılık bulmayabilir. Başarısız olan testi silme — önce araştır.Tamamlanma ölçütü: dbt test yeşil ve gevşettiğin ya da kaldırdığın her testin yanında ne bulduğunu açıklayan bir yorum var.

</details>
  

- [ ] **2.2 Composite key tests** `[TEST]`

  `order_items` is keyed on `(order_id, order_item_id)` and `order_payments` on `(order_id, payment_sequential)`. A single-column `unique` test can't express that.

  *Done when:* both grains are tested.

  <details>
<summary>🇹🇷 Türkçe</summary>

2.2 Bileşik anahtar testleri — order_items'ın anahtarı (order_id, order_item_id), order_payments'ınki (order_id, payment_sequential). Tek kolonluk bir unique testi bunu ifade edemez.Tamamlanma ölçütü: Her iki grain (kırılım) de test ediliyor.dbt_utils.unique_combination_of_columns. Alternatifi — dbt_utils.generate_surrogate_key ile bir surrogate key üretip onu test etmek — de geçerli ve alt katmanlarda daha faydalı. İkisini birden yapmayı düşün.

</details>
  
  <details>
<summary>Hint</summary>

dbt_utils.unique_combination_of_columns. The alternative — building a surrogate key with dbt_utils.generate_surrogate_key and testing that — is also valid and more useful downstream. Consider doing both.

</details>
  

- [ ] **2.3 dbt_expectations tests** `[TEST]`

  Add value-range and distribution tests where they express a real business rule: `price > 0`, `review_score` between 1 and 5, `payment_installments` within a sane bound, row-count sanity on marts.

  *Done when:* at least six expectation-style tests exist and each maps to a stated rule.

  <details>
<summary>🇹🇷 Türkçe</summary>

2.3 dbt_expectations testleri — Gerçek bir iş kuralını ifade ettikleri yerlerde değer aralığı ve dağılım testleri ekle: price > 0, review_score 1 ile 5 arasında, payment_installments makul bir sınırda, mart'larda satır sayısı kontrolü.Tamamlanma ölçütü: En az altı expectation tarzı test var ve her biri açıkça yazılmış bir kurala karşılık geliyor.

</details>
  

- [ ] **2.4 Write a custom generic test** `[TEST]`

  A test in `tests/generic/` that takes arguments and can be applied from YAML. Good candidate: `assert_no_future_dates`, or a positive-value test that permits a documented null rate.

  *Done when:* the test lives in YAML on at least two models.

  <details>
<summary>🇹🇷 Türkçe</summary>

2.4 Kendi generic testini yaz — tests/generic/ altında, argüman alan ve YAML'dan uygulanabilen bir test. İyi aday: assert_no_future_dates, ya da dokümante edilmiş bir null oranına izin veren bir pozitif değer testi.Tamamlanma ölçütü: Test en az iki modelin YAML'ında kullanılıyor.

</details>
  

- [ ] **2.5 Singular tests for the real traps** ⭐ `[TEST]`

  These are the tests that prove you understood the data:

  - **Revenue reconciliation** — total `payment_value` per order vs `sum(price + freight_value)` from items, within a tolerance. Catches fan-out bugs.
  - **Delivery sanity** — no `delivered_customer_date` earlier than `order_purchase_timestamp`.
  - **Fan-out guard** — `fct_orders` row count equals distinct `order_id` count.

  *Done when:* three singular tests exist in `tests/`, and you can explain what production bug each would catch.

  <details>
<summary>🇹🇷 Türkçe</summary>

2.5 Gerçek tuzaklar için singular testler ⭐ — Veriyi anladığını kanıtlayan testler bunlar:Gelir mutabakatı — sipariş başına toplam payment_value ile kalemlerden gelen sum(price + freight_value)'ı bir tolerans dahilinde karşılaştır. Fan-out (satır çoğalması) hatalarını yakalar.Teslimat mantık kontrolü — hiçbir delivered_customer_date, order_purchase_timestamp'ten önce olamaz.Fan-out koruması — fct_orders satır sayısı, distinct order_id sayısına eşit olmalı.Tamamlanma ölçütü: tests/ altında üç singular test var ve her birinin hangi production hatasını yakalayacağını açıklayabiliyorsun.

</details>
  

- [ ] **2.6 Unit tests** ⭐ `[TEST]`

  dbt 1.8+ `unit_tests:` — fixed input rows, asserted output rows, no warehouse data needed. Almost no portfolio project has these. Apply to your most logic-heavy model (the payment pivot or an RFM bucketing model).

  *Done when:* at least two unit tests run under `dbt test`, including one edge case (a null, or an order with zero payments).

  <details>
<summary>🇹🇷 Türkçe</summary>

2.6 Unit testler ⭐ — dbt 1.8+ ile gelen unit_tests: — sabit girdi satırları, beklenen çıktı satırları, warehouse verisine ihtiyaç yok. Portfolyo projelerinin neredeyse hiçbirinde yok. En çok mantık içeren modeline uygula (payment pivot ya da RFM segmentleme modeli).Tamamlanma ölçütü: dbt test altında en az iki unit test çalışıyor ve bunlardan biri bir uç durumu kapsıyor (bir null, ya da hiç ödemesi olmayan bir sipariş).Unit testler tests/ altında değil, modelin YAML'ında yer alır. ref/source fixture'ları içeren bir given: ve bir expect: bloğu isterler. dbt test --select test_type:unit ile çalıştır.

</details>
  
  <details>
<summary>Hint</summary>

Unit tests go in the model's YAML, not in tests/. They need given: with ref/ source fixtures and an expect: block. Run them with dbt test --select test_type:unit.

</details>
  

- [ ] **2.7 Test configuration** `[TEST]` `[MONITOR]`

  Use `severity: warn` where a failure is informational, `error_if`/`warn_if` thresholds where a small number of bad rows is tolerable, and `store_failures: true` on the tests worth investigating after the fact.

  *Done when:* not every test is a binary error, and the failure tables are queryable.

  <details>
<summary>🇹🇷 Türkçe</summary>

2.7 Test konfigürasyonu — Başarısızlığın bilgilendirme amaçlı olduğu yerlerde severity: warn, az sayıda hatalı satırın tolere edilebildiği yerlerde error_if/warn_if eşikleri, sonradan incelemeye değer testlerde store_failures: true kullan.Tamamlanma ölçütü: Her test ikili (geçti/kaldı) bir hata değil ve başarısızlık tabloları sorgulanabilir durumda.

</details>
  

---

## Phase 3 — Intermediate & Marts

Goal: a dimensional model a BI tool can sit on without further transformation.

<details>
<summary>🇹🇷 Türkçe</summary>

Faz 3 — Intermediate ve Mart'lar. Hedef: bir BI aracının ek dönüşüm yapmadan üzerine oturabileceği bir boyutsal (dimensional) model.

</details>

- [ ] **3.1 Resolve the payment fan-out** `[DEV]`

  `order_payments` has multiple rows per order. Build an intermediate model at **one row per order** carrying total paid, installment count, and a breakdown by payment type.

  *Done when:* the model has exactly one row per `order_id` and a test proves it.

  <details>
<summary>🇹🇷 Türkçe</summary>

3.1 Ödeme fan-out'unu çöz — order_payments sipariş başına birden fazla satır içeriyor. Sipariş başına tek satır olan bir intermediate model kur; toplam ödenen tutarı, taksit sayısını ve ödeme tipine göre kırılımı taşısın.Tamamlanma ölçütü: Model order_id başına tam olarak bir satır içeriyor ve bunu bir test kanıtlıyor.Aggregate ve pivot'u tek geçişte yap — sipariş bazında gruplayıp her tip için sum(case when payment_type = 'credit_card' then payment_value end). Elle yazmak istemezsen dbt_utils.pivot bunu distinct değerlerden üretebilir.

</details>
  
  <details>
<summary>Hint</summary>

Aggregate and pivot in one pass — sum(case when payment_type = 'credit_card' then payment_value end) per type, grouped by order. dbt_utils.pivot can generate this from the distinct values if you'd rather not hardcode.

</details>
  

- [ ] **3.2 Order items enriched** `[DEV]`

  Join items to products (with English categories) and sellers. Stays at line-item grain.

  *Done when:* row count is unchanged from `stg_olist__order_items` — a join that changes the row count is a bug.

  <details>
<summary>🇹🇷 Türkçe</summary>

3.2 Zenginleştirilmiş sipariş kalemleri — Kalemleri ürünlerle (İngilizce kategorilerle) ve satıcılarla join'le. Grain sipariş kalemi seviyesinde kalır.Tamamlanma ölçütü: Satır sayısı stg_olist__order_items ile aynı — satır sayısını değiştiren bir join hatadır.

</details>
  

- [ ] **3.3** `dim_customers` ⭐ `[DEV]`

  The headline trap. `customer_id` is one row per order; `customer_unique_id` is the actual person. Build the dimension at the **person** grain with first/last order date, lifetime order count, and lifetime value.

  *Done when:* the row count is materially lower than `stg_olist__customers`, and the model description explains the `customer_id` vs `customer_unique_id` distinction.

  <details>
<summary>🇹🇷 Türkçe</summary>

3.3 dim_customers ⭐ — Bu veri setinin en önemli tuzağı. customer_id sipariş başına bir satır; gerçek kişi customer_unique_id. Boyutu kişi grain'inde kur; ilk ve son sipariş tarihi, yaşam boyu sipariş sayısı ve yaşam boyu değer içersin.Tamamlanma ölçütü: Satır sayısı stg_olist__customers'tan belirgin şekilde düşük ve model açıklaması customer_id ile customer_unique_id farkını anlatıyor.

</details>
  

- [ ] **3.4** `dim_products` **and** `dim_sellers` `[DEV]`

  English categories, null category handled explicitly (an `'unknown'` bucket beats a null), physical dimensions cleaned.

  *Done when:* both build with full column-level docs.

  <details>
<summary>🇹🇷 Türkçe</summary>

3.4 dim_products ve dim_sellers — İngilizce kategoriler, null kategorilerin açıkça ele alınması (bir 'unknown' kovası null'dan iyidir), fiziksel ölçülerin temizlenmesi.Tamamlanma ölçütü: İkisi de kolon seviyesinde tam dokümantasyonla build oluyor.

</details>
  

- [ ] **3.5** `dim_geolocation` `[DEV]`

  61 MB, many noisy rows per zip prefix, inconsistent accented city names. Reduce to one row per `zip_code_prefix` with a representative coordinate and a canonical city name.

  *Done when:* one row per zip prefix, and you can state which centrality measure you chose for lat/lng and why.

  <details>
<summary>🇹🇷 Türkçe</summary>

3.5 dim_geolocation — 61 MB, zip prefix başına çok sayıda gürültülü satır, aksanlı ve tutarsız şehir isimleri. zip_code_prefix başına tek satıra indir; temsili bir koordinat ve standart bir şehir ismi taşısın.Tamamlanma ölçütü: Zip prefix başına bir satır var ve lat/lng için hangi merkezi eğilim ölçüsünü neden seçtiğini söyleyebiliyorsun.Ortalama, geocoding aykırı değerleri tarafından sürüklenir; medyan sürüklenmez. Ayrıca şehir isimlerindeki aksanları kaldırıp kaldırmayacağına ve bunun bilgi kaybı olup olmadığına karar ver.

</details>
  
  <details>
<summary>Hint</summary>

The mean is dragged around by geocoding outliers; the median is not. Also decide whether to strip accents for the city name and whether that's lossy.

</details>
  

- [ ] **3.6** `dim_date` `[DEV]`

  A date spine covering the dataset's range with the usual calendar attributes, plus Brazilian public holidays if you want to go further (holidays visibly move e-commerce volume — Black Friday 2017 is dramatic in this data).

  *Done when:* the spine is gapless across the full order date range.

  <details>
<summary>🇹🇷 Türkçe</summary>

3.6 dim_date — Veri setinin tarih aralığını kapsayan, alışıldık takvim özelliklerini içeren bir date spine; istersen Brezilya resmî tatillerini de ekle (tatiller e-ticaret hacmini gözle görülür şekilde etkiliyor — 2017 Black Friday bu veride çok belirgin).Tamamlanma ölçütü: Spine, tüm sipariş tarih aralığı boyunca boşluksuz.dbt_utils.date_spine, ya da hazır bir sürüm için dbt_date.get_date_dimension. Kendin üretmek öğrenme açısından daha iyi bir alıştırma.

</details>
  
  <details>
<summary>Hint</summary>

dbt_utils.date_spine, or dbt_date.get_date_dimension for a ready-made version. Generating your own is the better learning exercise.

</details>
  

- [ ] **3.7** `fct_orders` `[DEV]`

  One row per order. Foreign keys to every dimension, plus measures: item count, product revenue, freight, total paid, review score. Add the delivery timing measures — approval lag, delivery days, days early/late vs estimate, an on-time flag.

  *Done when:* one row per order, all FKs pass `relationships` tests, and revenue reconciles with the phase 2.5 test.

  <details>
<summary>🇹🇷 Türkçe</summary>

3.7 fct_orders — Sipariş başına tek satır. Her boyuta foreign key'ler, artı ölçütler: kalem sayısı, ürün geliri, kargo, toplam ödenen, review puanı. Teslimat zaman ölçütlerini de ekle — onay gecikmesi, teslimat gün sayısı, tahmine göre kaç gün erken/geç, ve bir zamanında-teslimat bayrağı.Tamamlanma ölçütü: Sipariş başına bir satır, tüm FK'ler relationships testlerini geçiyor ve gelir, faz 2.5'teki testle mutabık.

</details>
  

- [ ] **3.8** `fct_order_items` `[DEV]`

  Line-item grain with a surrogate key. Allocate order-level payment amounts down to the line proportionally — and be able to defend the allocation rule.

  *Done when:* allocated amounts sum back to the order total within tolerance.

  <details>
<summary>🇹🇷 Türkçe</summary>

3.8 fct_order_items — Surrogate key'li sipariş kalemi grain'i. Sipariş seviyesindeki ödeme tutarlarını kalem seviyesine orantılı olarak dağıt — ve dağıtım kuralını savunabil.Tamamlanma ölçütü: Dağıtılan tutarlar, tolerans dahilinde sipariş toplamına geri toplanıyor.

</details>
  

- [ ] **3.9 Analytical marts** ⭐ `[DEV]`

  This is where you show analytics judgment rather than plumbing. Build at least three:

  - `mart_customer_rfm` — recency/frequency/monetary scoring with named segments (Champions, At Risk, Hibernating). Note the honest caveat: most Olist customers order exactly once, which makes the F dimension nearly degenerate. Saying so is stronger than hiding it.
  - `mart_seller_scorecard` — per seller: volume, revenue, average review, on-time rate, average shipping lag. Rank within category.
  - `mart_delivery_performance` — on-time rate by state, category, and month; the relationship between delivery delay and review score. (There's a strong real signal here — late deliveries tank review scores. That's your headline chart.)
  - `mart_cohort_retention` — monthly acquisition cohorts by repeat purchase rate.
  - `mart_category_monthly` — the category × month aggregate for trend charts.

  *Done when:* three or more exist, each documented with the question it answers.

  <details>
<summary>🇹🇷 Türkçe</summary>

3.9 Analitik mart'lar ⭐ — Burada tesisatçılık değil, analitik muhakeme gösteriyorsun. En az üç tane kur:mart_customer_rfm — recency/frequency/monetary skorlaması ve isimlendirilmiş segmentler (Champions, At Risk, Hibernating). Dürüst uyarıyı da not et: Olist müşterilerinin çoğu tam olarak bir kez sipariş veriyor, bu da F boyutunu neredeyse işlevsiz bırakıyor. Bunu söylemek, gizlemekten daha güçlü.mart_seller_scorecard — satıcı başına: hacim, gelir, ortalama review, zamanında teslimat oranı, ortalama kargoya veriliş gecikmesi. Kategori içinde sırala.mart_delivery_performance — eyalete, kategoriye ve aya göre zamanında teslimat oranı; teslimat gecikmesi ile review puanı arasındaki ilişki. (Burada güçlü ve gerçek bir sinyal var — geç teslimatlar review puanlarını çökertiyor. Manşet grafiğin bu olacak.)mart_cohort_retention — aylık kazanım kohortları ve tekrar satın alma oranı.mart_category_monthly — trend grafikleri için kategori × ay kırılımı.Tamamlanma ölçütü: Üç veya daha fazlası mevcut ve her biri hangi soruyu cevapladığıyla birlikte dokümante edilmiş.

</details>
  

---

## Phase 4 — Advanced Materializations & the Ingestion Clock ⭐

Goal: prove you can handle production patterns — not just rebuild everything nightly. This phase is the biggest single differentiator in the project.

<details>
<summary>🇹🇷 Türkçe</summary>

Faz 4 — İleri Materialization'lar ve Yükleme Saati ⭐ — Hedef: production kalıplarını yönetebildiğini kanıtlamak; her gece her şeyi baştan kurmak değil. Bu faz projedeki en büyük tek farklılaştırıcı.

</details>

- [ ] **4.1 Build a simulated ingestion clock** ⭐ `[DEV]`

  The problem: Olist is a static 2018 dump, so incremental models and snapshots are meaningless theater on it. The fix: `scripts/simulate_load.py --as-of YYYY-MM-DD` that loads into `raw` only the records that existed as of that date, and mutates order status to what it was then (an order delivered in March is still `shipped` if you're standing in February).

  Now you can advance the clock day by day and watch incremental logic and SCD2 history actually work.

  *Done when:* running with two different `--as-of` dates produces genuinely different `raw.orders` content, including changed statuses.

  <details>
<summary>🇹🇷 Türkçe</summary>

4.1 Simüle edilmiş yükleme saati kur ⭐ — Sorun: Olist 2018'den kalma statik bir döküm, dolayısıyla incremental modeller ve snapshot'lar bunun üzerinde anlamsız bir tiyatro. Çözüm: scripts/simulate_load.py --as-of YYYY-MM-DD — raw'a yalnızca o tarih itibarıyla var olan kayıtları yükler ve sipariş statüsünü o günkü haline çevirir (Mart'ta teslim edilmiş bir sipariş, Şubat'ta duruyorsan hâlâ shipped'tir).Böylece saati gün gün ileri alıp incremental mantığın ve SCD2 geçmişinin gerçekten çalıştığını görebilirsin.Tamamlanma ölçütü: İki farklı --as-of tarihiyle çalıştırmak, statüler dahil gerçekten farklı raw.orders içeriği üretiyor.Satırları order_purchase_timestamp <= as_of ile filtrele. Statü için timestamp kolonlarını geriye doğru yürü: eğer delivered_customer_date > as_of ise sipariş henüz teslim edilmemiştir — hangi timestamp'lerin geçtiğine bakarak sırasıyla shipped, approved, created'a düş. Asıl alıştırma bu geriye yürüyüş.

</details>
  
  <details>
<summary>Hint</summary>

Filter rows on order_purchase_timestamp <= as_of. For status, walk the timestamp columns backwards: if delivered_customer_date > as_of then the order wasn't delivered yet — fall back to shipped, then approved, then created, based on which timestamps have passed. That backwards walk is the exercise.

</details>
  

- [ ] **4.2 Incremental** `fct_order_items` `[DEV]` `[DEBUG]`

  Convert to `materialized: incremental` with a `unique_key` and an `is_incremental()`filter. Test it properly with the clock from 4.1: full refresh at an early date, then advance and run incrementally, then compare against a full refresh at the later date.

  *Done when:* incremental output matches full-refresh output exactly, and you've understood the `on_schema_change` options.

  <details>
<summary>🇹🇷 Türkçe</summary>

4.2 Incremental fct_order_items — Modeli unique_key ve is_incremental() filtresi ile materialized: incremental'a çevir. 4.1'deki saatle düzgün test et: erken bir tarihte full refresh yap, sonra saati ilerletip incremental çalıştır, sonra geç tarihteki bir full refresh ile karşılaştır.Tamamlanma ölçütü: Incremental çıktı, full refresh çıktısıyla birebir aynı ve on_schema_change seçeneklerini anlamış durumdasın.

</details>
  

- [ ] **4.3 Handle late-arriving data** ⭐ `[DEV]`

  A naive `where updated_at > (select max(...) from {{ this }})` silently drops records that arrive out of order. Add a lookback window and show that it recovers rows a naive filter would lose.

  *Done when:* you can demonstrate the failure case, then the fix.

  <details>
<summary>🇹🇷 Türkçe</summary>

4.3 Geç gelen veriyi ele al ⭐ — Naif bir where updated_at > (select max(...) from {{ this }}) filtresi, sırasız gelen kayıtları sessizce düşürür. Bir geriye bakış penceresi (lookback window) ekle ve naif filtrenin kaybedeceği satırları kurtardığını göster.Tamamlanma ölçütü: Önce hatalı durumu, sonra düzeltmeyi gösterebiliyorsun.

</details>
  

- [ ] **4.4 Snapshot order status (SCD2)** ⭐ `[DEV]`

  Snapshot `orders` on `order_status` with the `check` strategy. Advance the clock across several dates, snapshotting each time, and build the SCD2 history of orders moving `created → approved → shipped → delivered`.

  *Done when:* the snapshot table holds multiple versions of the same `order_id` with correct `dbt_valid_from` / `dbt_valid_to`.

  <details>
<summary>🇹🇷 Türkçe</summary>

4.4 Sipariş statüsünü snapshot'la (SCD2) ⭐ — orders'ı order_status üzerinden check stratejisiyle snapshot'la. Saati birkaç tarih boyunca ilerlet, her seferinde snapshot al ve siparişlerin created → approved → shipped → delivered hareketinin SCD2 geçmişini oluştur.Tamamlanma ölçütü: Snapshot tablosu aynı order_id için doğru dbt_valid_from / dbt_valid_to değerleriyle birden fazla versiyon tutuyor.

</details>
  

- [ ] **4.5 Build a status-duration model on the snapshot** `[DEV]`

  Use the SCD2 history to measure how long orders sit in each status — which is a real operational metric you *cannot* compute from the static dump. This is the payoff for phase 4.

  *Done when:* average duration per status transition is queryable.

  <details>
<summary>🇹🇷 Türkçe</summary>

4.5 Snapshot üzerine statü süresi modeli kur — SCD2 geçmişini kullanarak siparişlerin her statüde ne kadar beklediğini ölç — bu, statik dökümden hesaplayamayacağın gerçek bir operasyonel metrik. Faz 4'ün getirisi bu.Tamamlanma ölçütü: Statü geçişi başına ortalama süre sorgulanabiliyor.

</details>
  

- [ ] **4.6 Ephemeral models and a custom macro** `[DEV]`

  Use `materialized: ephemeral` where a model is pure plumbing, and inspect the compiled SQL to see it inlined. Write one genuinely reusable macro (a `cents_to_currency`rounder, a status-grouping `case` expression) and use it in three or more models.

  *Done when:* `dbt compile` shows the ephemeral model inlined, and the macro is documented in `macros/_macros.yml`.

  <details>
<summary>🇹🇷 Türkçe</summary>

4.6 Ephemeral modeller ve kendi makron — Bir model saf tesisatsa materialized: ephemeral kullan ve derlenmiş SQL'e bakıp inline edildiğini gör. Gerçekten yeniden kullanılabilir bir makro yaz (bir cents_to_currency yuvarlayıcı, ya da statü gruplayan bir case ifadesi) ve üç veya daha fazla modelde kullan.Tamamlanma ölçütü: dbt compile ephemeral modeli inline gösteriyor ve makro macros/_macros.yml içinde dokümante edilmiş.

</details>
  

---

## Phase 5 — Governance & Documentation

Goal: the things that separate a course project from a project on a real team.

<details>
<summary>🇹🇷 Türkçe</summary>

Faz 5 — Yönetişim ve Dokümantasyon. Hedef: bir kurs projesini gerçek bir takımdaki projeden ayıran şeyler.

</details>

- [ ] **5.1 Contracts and constraints on marts** ⭐ `[GOV]`

  `contract: {enforced: true}` on your mart models with column types and constraints declared. dbt then refuses to build a model whose shape drifted.

  *Done when:* an intentional type change fails the build with a contract error — verify it, then revert. Note that DuckDB enforces only some constraint types; document which are checked vs informational.

  <details>
<summary>🇹🇷 Türkçe</summary>

5.1 Mart'larda contract ve constraint'ler ⭐ — Mart modellerine kolon tipleri ve constraint'ler tanımlanmış şekilde contract: {enforced: true} ekle. Böylece dbt, şekli kaymış bir modeli build etmeyi reddeder.Tamamlanma ölçütü: Kasıtlı bir tip değişikliği build'i contract hatasıyla düşürüyor — bunu doğrula, sonra geri al. DuckDB'nin yalnızca bazı constraint tiplerini zorladığını unutma; hangilerinin gerçekten kontrol edildiğini, hangilerinin sadece bilgi amaçlı olduğunu dokümante et.

</details>
  

- [ ] **5.2 Model versions** `[GOV]`

  Version a mart (`fct_orders` v1 → v2 with a breaking change), with `latest_version` and a `deprecation_date` on v1.

  *Done when:* both versions build, and `ref('fct_orders')` resolves to the version you intended.

  <details>
<summary>🇹🇷 Türkçe</summary>

5.2 Model versiyonlama — Bir mart'ı versiyonla (fct_orders v1 → v2, aralarında kırıcı bir değişiklikle), latest_version ve v1'de bir deprecation_date ile.Tamamlanma ölçütü: İki versiyon da build oluyor ve ref('fct_orders') amaçladığın versiyona çözümleniyor.

</details>
  

- [ ] **5.3 Groups and access** `[GOV]`

  Define groups with owners in YAML. Set `access: private` on staging and intermediate, `access: public` on marts.

  *Done when:* a deliberate cross-group `ref()` of a private model raises an error.

  <details>
<summary>🇹🇷 Türkçe</summary>

5.3 Group'lar ve erişim — YAML'da sahipleriyle birlikte group'lar tanımla. Staging ve intermediate'e access: private, mart'lara access: public ver.Tamamlanma ölçütü: Private bir modele kasıtlı olarak gruplar arası ref() yapmak hata veriyor.

</details>
  

- [ ] **5.4 Exposures** `[GOV]` `[MONITOR]`

  Declare your Evidence dashboard (phase 7) as an exposure with owner and depends-on. This makes downstream impact visible in the DAG — `dbt build --select +exposure:...`becomes meaningful.

  *Done when:* the exposure appears in the docs site with its lineage.

  <details>
<summary>🇹🇷 Türkçe</summary>

5.4 Exposure'lar — Evidence dashboard'unu (faz 7) sahibi ve bağımlılıklarıyla birlikte bir exposure olarak tanımla. Bu, alt akış etkisini DAG'da görünür kılar — dbt build --select +exposure:... anlamlı hale gelir.Tamamlanma ölçütü: Exposure, lineage'iyle birlikte docs sitesinde görünüyor.

</details>
  

- [ ] **5.5 Documentation pass** `[GOV]`

  Doc blocks for anything repeated, a custom `overview.md` for the docs landing page, `persist_docs` enabled so descriptions land in the database catalog.

  *Done when:* the docs site opens on your own overview page, not dbt's default.

  <details>
<summary>🇹🇷 Türkçe</summary>

5.5 Dokümantasyon turu — Tekrarlanan her şey için doc block'lar, docs açılış sayfası için özel bir overview.md, ve açıklamaların veritabanı kataloğuna işlenmesi için persist_docs açık.Tamamlanma ölçütü: Docs sitesi dbt'nin varsayılanıyla değil, senin yazdığın overview sayfasıyla açılıyor.

</details>
  

---

## Phase 6 — Deployment & CI/CD ⭐

Goal: a green badge and a public docs URL. This is the part hiring managers actually click.

<details>
<summary>🇹🇷 Türkçe</summary>

Faz 6 — Dağıtım ve CI/CD ⭐ — Hedef: yeşil bir badge ve herkese açık bir docs URL'i. İşe alım yapanların gerçekten tıkladığı kısım burası.

</details>

- [ ] **6.1 CI on pull requests** ⭐ `[DEPLOY]`

  A GitHub Actions workflow that on every PR installs the locked environment, seeds the sample data from 0.5, and runs `dbt build`. Since DuckDB is a file, CI needs no warehouse credentials at all — this project can have genuinely free, fast CI, which most portfolio dbt projects cannot.

  *Done when:* a PR shows a green check, and a deliberately broken model turns it red.

  <details>
<summary>🇹🇷 Türkçe</summary>

6.1 Pull request'lerde CI ⭐ — Her PR'da lock'lanmış ortamı kuran, 0.5'teki örneklem veriyi seed'leyen ve dbt build çalıştıran bir GitHub Actions workflow'u. DuckDB bir dosya olduğu için CI'ın hiçbir warehouse kimlik bilgisine ihtiyacı yok — bu proje gerçekten ücretsiz ve hızlı bir CI'a sahip olabilir, ki portfolyo dbt projelerinin çoğu bunu yapamaz.Tamamlanma ölçütü: Bir PR yeşil tik gösteriyor ve kasıtlı olarak bozulmuş bir model onu kırmızıya çeviriyor.0.5'in önemi tam olarak burada — commit'lenmiş seed'ler olmadan CI'ın verisi olmaz.astral-sh/setup-uv action'ını enable-cache: true ile kullan, sonra uv sync --locked. --locked bayrağı, uv.lock ile pyproject.toml birbirinden ayrıştıysa CI'ı düşürür — istediğin davranış bu, çünkü birinin lock'lamayı unuttuğu bir bağımlılık değişikliğini yakalar. dbt_packages/'i ayrıca cache'le.

</details>
  
  <details>
<summary>Hint</summary>

This is exactly why 0.5 matters — without committed seeds, CI has no data.Use the astral-sh/setup-uv action with enable-cache: true, then uv sync --locked. The --locked flag makes CI fail if uv.lock is out of sync with pyproject.toml, which is the behaviour you want — it catches a dependency change someone forgot to lock. Cache dbt_packages/ separately.

</details>
  

- [ ] **6.2 Slim CI with state comparison** ⭐ `[STATE]` `[DEPLOY]`

  Build only what changed: `dbt build --select state:modified+ --defer --state ./prod-run-artifacts`. Requires publishing `manifest.json` from a main-branch run and downloading it in the PR job.

  *Done when:* a PR touching one staging model builds that model and its children, not the whole project — and the log proves it.

  <details>
<summary>🇹🇷 Türkçe</summary>

6.2 State karşılaştırmalı Slim CI ⭐ — Yalnızca değişeni build et: dbt build --select state:modified+ --defer --state ./prod-run-artifacts. Bunun için master dalındaki bir çalıştırmadan manifest.json yayınlaman ve PR job'ında indirmen gerekiyor.Tamamlanma ölçütü: Tek bir staging modeline dokunan bir PR, tüm projeyi değil, o modeli ve altındakileri build ediyor — ve log bunu kanıtlıyor.Production manifest.json'ını bir GitHub Actions artifact'ı olarak sakla ya da özel bir dala commit'le. state:modified ile state:new ve result:error arasındaki farkı ve --defer'ın build edilmemiş ref'leri nasıl çözdüğünü anlamak doğrudan sınav konusu.

</details>
  
  <details>
<summary>Hint</summary>

Store the production manifest.json as a GitHub Actions artifact or commit it to a dedicated branch. Understanding state:modified vs state:new vs result:error, and how --defer resolves unbuilt refs, is directly on the exam.

</details>
  

- [ ] **6.3 Scheduled production run** `[DEPLOY]` `[MONITOR]`

  A `schedule:` workflow that runs the full build, uploads `manifest.json` and `run_results.json` as artifacts, and fails loudly.

  *Done when:* the scheduled run has succeeded at least once unattended.

  <details>
<summary>🇹🇷 Türkçe</summary>

6.3 Zamanlanmış production çalıştırması — Tam build'i çalıştıran, manifest.json ve run_results.json'ı artifact olarak yükleyen ve hata durumunda gürültülü şekilde düşen bir schedule: workflow'u.Tamamlanma ölçütü: Zamanlanmış çalıştırma en az bir kez, sen başında olmadan başarılı oldu.

</details>
  

- [ ] **6.4 Publish dbt docs to GitHub Pages** ⭐ `[DEPLOY]`

  `dbt docs generate` and deploy `target/` to GitHub Pages. **A public, browsable lineage DAG is a link you can put directly on your CV** — a reviewer sees your whole model graph in ten seconds without cloning anything. Highest impact-per-hour item in this roadmap.

  *Done when:* the docs site is live at a public URL and the lineage graph renders.

  <details>
<summary>🇹🇷 Türkçe</summary>

6.4 dbt docs'u GitHub Pages'te yayınla ⭐ — dbt docs generate çalıştır ve target/klasörünü GitHub Pages'e dağıt. Herkese açık, gezinilebilir bir lineage DAG'ı doğrudan CV'ne koyabileceğin bir link — inceleyen kişi hiçbir şey klonlamadan on saniyede tüm model grafiğini görüyor. Bu yol haritasındaki saat başına en yüksek getirili madde.Tamamlanma ölçütü: Docs sitesi herkese açık bir URL'de canlı ve lineage grafiği render oluyor.Üretilen site statik — index.html artı manifest.json ve catalog.json. Faz 7'nin site kökünü alabilmesi için bunu bir alt yola (/docs/) dağıt.

</details>
  
  <details>
<summary>Hint</summary>

The generated site is static — index.html plus manifest.json and catalog.json. Deploy it to a subpath (/docs/) so phase 7 can take the site root.

</details>
  

- [ ] **6.5 Pipeline monitoring** `[MONITOR]`

  Parse `run_results.json` after each run into a small report: slowest models, test failures, total runtime. Optionally load the artifacts back into DuckDB and model them — dbt modeling its own metadata is a nice touch.

  *Done when:* a failing run produces a readable summary, not a wall of logs.

  <details>
<summary>🇹🇷 Türkçe</summary>

6.5 Pipeline izleme — Her çalıştırmadan sonra run_results.json'ı küçük bir rapora dönüştür: en yavaş modeller, başarısız testler, toplam süre. İstersen artifact'ları DuckDB'ye geri yükleyip modelle — dbt'nin kendi metadata'sını modellemesi hoş bir dokunuş.Tamamlanma ölçütü: Başarısız bir çalıştırma, log yığını değil okunabilir bir özet üretiyor.

</details>
  

---

## Phase 7 — BI Layer ⭐

Goal: a live dashboard URL. **Evidence.dev**, not Streamlit — Evidence reads DuckDB natively and builds a *static* site, so GitHub Pages hosts it free with no server. Node v24 is already installed.

<details>
<summary>🇹🇷 Türkçe</summary>

Faz 7 — BI Katmanı ⭐ — Hedef: canlı bir dashboard URL'i. Streamlit değil Evidence.dev — Evidence DuckDB'yi doğrudan okuyor ve statik bir site üretiyor, dolayısıyla GitHub Pages onu sunucusuz ve ücretsiz barındırıyor. Node v24 zaten kurulu.

</details>

- [ ] **7.1 Set up Evidence** `[DEPLOY]`

  Scaffold under `reports/`, point its DuckDB connection at the built warehouse, verify it queries your marts. Gitignore Evidence's build output.

  *Done when:* `npm run dev` renders a page fed by a real mart query.

  <details>
<summary>🇹🇷 Türkçe</summary>

7.1 Evidence'ı kur — reports/ altında iskeleti oluştur, DuckDB bağlantısını kurulmuş warehouse'a yönlendir, mart'larını sorguladığını doğrula. Evidence'ın build çıktısını gitignore'a ekle.Tamamlanma ölçütü: npm run dev, gerçek bir mart sorgusundan beslenen bir sayfa render ediyor.

</details>
  

- [ ] **7.2 Build the pages**

  Four pages, each answering a question rather than dumping a table:

  1. **Executive overview** — revenue trend, order volume, AOV, review average.
  2. **Delivery performance** — on-time rate by state (map), and the delay-vs-review-score relationship. This is your strongest finding; lead with it.
  3. **Seller scorecard** — searchable ranked table with drill-down.
  4. **Customer cohorts** — retention heatmap and RFM segment breakdown.

  *Done when:* every page reads from a mart, with no business logic in the dashboard layer. Transformation belongs in dbt — that's the whole thesis of the project.

  <details>
<summary>🇹🇷 Türkçe</summary>

7.2 Sayfaları kur — Dört sayfa; her biri tablo dökmek yerine bir soruyu cevaplasın:Yönetici özeti — gelir trendi, sipariş hacmi, sepet ortalaması, review ortalaması.Teslimat performansı — eyalete göre zamanında teslimat oranı (harita) ve gecikme ile review puanı arasındaki ilişki. En güçlü bulgun bu; onunla başla.Satıcı karnesi — aranabilir, sıralanmış ve detaya inilebilen tablo.Müşteri kohortları — retention ısı haritası ve RFM segment kırılımı.Tamamlanma ölçütü: Her sayfa bir mart'tan okuyor ve dashboard katmanında hiç iş mantığı yok. Dönüşüm dbt'ye aittir — projenin bütün tezi bu.

</details>
  

- [ ] **7.3 Deploy the dashboard** ⭐ `[DEPLOY]`

  Extend CI to build Evidence and publish it to GitHub Pages at the site root, with dbt docs at `/docs/`.

  *Done when:* two public URLs — dashboard and lineage — both refreshed automatically.

  <details>
<summary>🇹🇷 Türkçe</summary>

7.3 Dashboard'u dağıt ⭐ — CI'ı, Evidence'ı build edip GitHub Pages'te site köküne yayınlayacak şekilde genişlet; dbt docs /docs/ altında kalsın.Tamamlanma ölçütü: İki herkese açık URL — dashboard ve lineage — ikisi de otomatik güncelleniyor.

</details>
  

---

## Phase 8 — Portfolio Polish

Goal: a stranger understands the project's value in ninety seconds.

<details>
<summary>🇹🇷 Türkçe</summary>

Faz 8 — Portfolyo Cilası. Hedef: projeyi hiç bilmeyen biri değerini doksan saniyede anlasın.

</details>

- [ ] **8.1 README**

  Structure: one-line pitch → live links (dashboard, docs) → architecture diagram → three interesting findings with numbers → the modeling decisions you're proudest of → local setup. Put the links **above the fold**, before setup instructions.

  The current `README.md` is a setup guide. This task turns it into the portfolio front door — keep the setup content, move it down.

  *Done when:* someone who has never used dbt understands what you built and why.

  <details>
<summary>🇹🇷 Türkçe</summary>

8.1 README — Yapı: tek cümlelik tanıtım → canlı linkler (dashboard, docs) → mimari diyagram → sayılarla üç ilginç bulgu → en gurur duyduğun modelleme kararları → yerel kurulum. Linkleri kurulum talimatlarından önce, sayfanın üstüne koy.Mevcut README.md bir kurulum kılavuzu. Bu görev onu portfolyo vitrinine çeviriyor — kurulum içeriğini koru, aşağı taşı.Tamamlanma ölçütü: Hiç dbt kullanmamış biri ne kurduğunu ve neden kurduğunu anlıyor.

</details>
  

- [ ] **8.2 Architecture diagram**

  A Mermaid diagram in the README: CSV → DuckDB raw → staging → intermediate → marts → Evidence, with CI annotated. Mermaid renders natively on GitHub — no image files.

  <details>
<summary>🇹🇷 Türkçe</summary>

8.2 Mimari diyagram — README'de bir Mermaid diyagramı: CSV → DuckDB raw → staging → intermediate → marts → Evidence, üzerinde CI işaretli. Mermaid GitHub'da doğrudan render oluyor — görsel dosyaya gerek yok.

</details>
  

- [ ] **8.3 The interesting findings**

  Three concrete, quantified insights from your marts. "Orders delivered more than N days late average a review score of X versus Y for on-time" beats any amount of listed tooling. Numbers, not adjectives.

  <details>
<summary>🇹🇷 Türkçe</summary>

8.3 İlginç bulgular — Mart'larından çıkan üç somut, sayısallaştırılmış içgörü. "N günden fazla geç teslim edilen siparişlerin ortalama review puanı X, zamanında teslim edilenlerin Y" cümlesi, sıralanmış herhangi bir araç listesinden daha güçlüdür. Sıfat değil, sayı.

</details>
  

- [ ] **8.4 CV entry**

  Two lines, both with links: what the pipeline does and its scale (model count, test count, row count), plus the stack. Let the live docs link carry the proof.

  <details>
<summary>🇹🇷 Türkçe</summary>

8.4 CV maddesi — İki satır, ikisi de linkli: pipeline'ın ne yaptığı ve ölçeği (model sayısı, test sayısı, satır sayısı), artı kullanılan stack. Kanıtı canlı docs linki taşısın.

</details>
  

- [ ] **8.5 Certification self-check**

  Walk the coverage table below. Anything unchecked is a gap to close before the exam — either in the project or in dedicated study.

  <details>
<summary>🇹🇷 Türkçe</summary>

8.5 Sertifika öz değerlendirmesi — Aşağıdaki kapsam tablosunu baştan sona geç. İşaretlenmemiş her şey, sınavdan önce kapatman gereken bir boşluk — ya proje içinde ya da ayrı çalışmayla.

</details>
  

---

## Certification coverage

| Domain | Covered by |
| --- | --- |
| **Developing dbt models** | 1.3, 1.4, 3.1–3.9, 4.2, 4.6 — layers, materializations, refs, sources, seeds, macros, Jinja |
| **Debugging data modeling errors** | 0.2, 2.1, 4.2 — `dbt debug`, compiled SQL, logs, fan-out and grain bugs |
| **Implementing dbt tests** | 2.1–2.7 — generic, custom generic, singular, unit, severity, `store_failures` |
| **Monitoring data pipelines** | 1.2, 2.7, 5.4, 6.3, 6.5 — freshness, artifacts, exposures, scheduled runs |
| **Deploying dbt jobs** | 6.1–6.4, 7.3 — CI/CD, environments, scheduling, docs deployment |
| **Understanding dbt state** | 6.2 — `state:modified`, `--defer`, artifacts, slim CI |
| **Understanding governance** | 5.1–5.5 — contracts, versions, groups, access, exposures, docs |

**Weakest coverage:** dbt state. It's the domain most people under-practise because it needs a real deployment to exercise. Task 6.2 is the only place you'll meet it — don't skip it.

**Not covered by this project:** dbt Cloud specifics (job UI, IDE, environment variables, Cloud-only scheduling) and warehouse-specific behavior. Study those separately — the exam assumes dbt Cloud familiarity that a local DuckDB project can't give you.

<details>
<summary>🇹🇷 Türkçe</summary>

Sertifika kapsamı — Yukarıdaki tablo her sınav alanını onu çalıştıran görevlere bağlıyor.En zayıf kapsam: dbt state. İnsanların en az pratik yaptığı alan, çünkü gerçek bir deployment olmadan çalıştırılamıyor. Bu projede yalnızca görev 6.2'de karşına çıkacak — onu atlama.Bu projenin kapsamadıkları: dbt Cloud'a özgü konular (job arayüzü, IDE, ortam değişkenleri, yalnızca Cloud'da olan zamanlama) ve warehouse'a özgü davranışlar. Bunları ayrıca çalış — sınav, yerel bir DuckDB projesinin veremeyeceği bir dbt Cloud aşinalığı varsayıyor.

</details>

