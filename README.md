
# 🎥 XAI Advanced 3-Mode Third Person Camera

[![AMX Mod X](https://img.shields.io/badge/AMX%20Mod%20X-GoldSrc-orange.svg)](https://www.amxmodx.org/)
[![Engine](https://img.shields.io/badge/Engine-GoldSrc-brightgreen.svg)]()
[![Version](https://img.shields.io/badge/Version-2.2.1-blue.svg)]()
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Author](https://img.shields.io/badge/Author-@xansuz-red.svg)](https://github.com/xansuz)

**XAI Advanced 3-Mode Third Person Camera**, GoldSrc tabanlı sunucular için geliştirilmiş, oyuncu başına bağımsız çalışan, 3 farklı kamera perspektifi sunan ve gerçek zamanlı duvar çarpışma kontrolü uygulayan AMX Mod X eklentisidir.

> **Current plugin version:** `2.2.1`

**Repository:**  
https://github.com/xansuz/GoldSrc-Advanced-Thirdperson

**Developer:** [@xansuz](https://github.com/xansuz)

---

## 🌍 Language Navigation

- [🇹🇷 Türkçe](#-türkçe)
- [🇬🇧 English](#-english)
- [🇷🇺 Русский](#-русский)
- [🇷🇴 Română](#-română)
- [🇫🇷 Français](#-français)

---

# 🇹🇷 Türkçe

## 📖 Genel Bakış

XAI Advanced Third Person, GoldSrc kamera sistemini oyuncu bazında değiştiren gelişmiş bir üçüncü şahıs kamera eklentisidir.

Eklenti:

- Oyuncu başına ayrı kamera modu saklar.
- Kamera görünümünü gerçek zamanlı olarak günceller.
- 3 farklı üçüncü şahıs perspektifi sunar.
- Duvarlara doğru hareket eden kamerayı `TraceLine` ile kontrol eder.
- Kamera bir engelle karşılaştığında konumu güvenli bir noktaya geri çeker.
- Ölüm sırasında kamera entity'sini temizler.
- Oyuncu yeniden doğduğunda seçili kamera modunu yeniden uygular.
- Oyuncu sunucudan ayrıldığında kamera entity'sini temizler.
- `xai_main_menu` mevcutsa menüye kendisini otomatik olarak kaydeder.
- `xai_main_menu` yoksa bağımsız çalışır.
- Oyuncu `config.cfg` dosyasına zorla bind/config yazmaz.
- Harici model veya özel kamera asset'i gerektirmez.

---

## ✨ Özellikler

### 🎥 3 Ayrı Kamera Modu

| Mod | Ad | Açıklama |
| :---: | :--- | :--- |
| `0` | Birinci Şahıs | Kamera tamamen kapalı, normal oyuncu görünümü |
| `1` | Yakın Omuz | Oyuncunun arkasında yakın üçüncü şahıs görünümü |
| `2` | Geniş Taktiksel | Daha uzak, daha geniş üçüncü şahıs görünümü |
| `3` | Sinematik Ön | Oyuncunun önüne geçen, 180° ters çevrilmiş sinematik görünüm |

### 🧱 Gerçek Zamanlı Duvar Çarpışma Kontrolü

Kamera, oyuncunun göz konumundan hedef kamera konumuna doğru gerçek zamanlı `TraceLine` kontrolü yapar.

Bir duvar veya engel tespit edildiğinde:

1. Trace sonucu okunur.
2. Çarpışma noktası alınır.
3. `xai_tp_padding` tamponu uygulanır.
4. Kamera güvenli bir noktaya geri çekilir.

Bu sayede kamera hedef konumunun doğrudan içine gömülmek yerine engelin önünde tutulur.

> Not: Sistem bir `TraceLine` tabanlı kamera çözümlemesi kullanır; tam hacimsel kamera/corner sweep sistemi değildir.

---

## 👤 Oyuncu Bazlı Kamera Durumu

Her oyuncunun kamera durumu bağımsız olarak tutulur.

Bir oyuncu:

- Mod 0 kullanabilirken başka bir oyuncu Mod 1 kullanabilir.
- Mod 2 kullanabilirken başka bir oyuncu Mod 3 kullanabilir.
- Kendi kamera modunu değiştirirken diğer oyuncuların kamera durumunu etkilemez.

Yeni bağlanan oyuncular varsayılan olarak:

```text
Mode 0 = First Person / Camera OFF
```

ile başlatılır.

---

## 🔄 Ölüm / Spawn / Disconnect Davranışı

Eklenti kamera entity'sinin yaşam döngüsünü yönetir.

### Oyuncu ölürse

Kamera entity'si temizlenir ve oyuncunun görünümü normale döndürülür.

### Oyuncu yeniden doğarsa

Oyuncunun seçili üçüncü şahıs modu `0` değilse kamera yeniden oluşturulur.

### Oyuncu ayrılırsa

Kamera entity'si temizlenir ve oyuncunun kamera durumu sıfırlanır.

Bu yapı, eski oyunculara ait kamera entity'lerinin sunucuda kalmasını önlemek için kullanılır.

---

## 🧩 XAI Main Menu Entegrasyonu

Eklenti `xai_main_menu` bulunduğunda kendisini ana menüye otomatik olarak kaydeder.

Menüde kayıt edilen öğe:

```text
Third Person Kamera [F1 / 3 Mod]
```

ve komut:

```text
xai_thirdperson
```

olarak kullanılır.

Entegrasyon yaklaşık plugin başlangıcından sonra otomatik olarak kontrol edilir.

### Main menu yoksa?

Hiçbir problem oluşturmaz.

Eklenti:

```text
Standalone Mode
```

olarak bağımsız çalışır ve aşağıdaki komutlar doğrudan kullanılabilir.

---

## 🎮 Komutlar

### Ana kamera değiştirme komutu

```text
xai_thirdperson
```

Her kullanımda kamera şu sırayla ilerler:

```text
0 → 1 → 2 → 3 → 0
```

Yani:

```text
First Person
   ↓
Mode 1 - Close Shoulder
   ↓
Mode 2 - Tactical
   ↓
Mode 3 - Cinematic Front
   ↓
First Person
```

---

### XAI ana komutu

```text
xai tp
```

veya:

```text
xai thirdperson
```

aynı kamera geçiş mekanizmasını çalıştırır.

---

### Belirli modu doğrudan seçme

```text
xai_tp_mode <0-3>
```

Örnek:

```text
xai_tp_mode 0
xai_tp_mode 1
xai_tp_mode 2
xai_tp_mode 3
```

Geçersiz bir değer verilirse:

```text
0
```

moduna geri dönülür.

---

## 💬 Chat Komutları

Aşağıdaki chat komutları kamera modunu değiştirir:

```text
/tp
!tp
/thirdperson
```

Team chat üzerinden de:

```text
/tp
```

kullanılabilir.

---

## ⌨️ F1 Bind

Önerilen oyuncu bind'i:

```text
bind F1 xai_thirdperson
```

Bu bind oyuncunun kendi client konsolundan yapılır.

Eklenti oyuncunun `config.cfg` dosyasını otomatik olarak değiştirmez ve zorla bind yazmaz.

---

## ⚙️ CVAR Ayarları

Eklenti aşağıdaki CVAR'ları kaydeder:

| CVAR | Varsayılan | Runtime Aralığı | Açıklama |
| :--- | ---: | :---: | :--- |
| `xai_tp_close_distance` | `88.0` | `40.0 - 320.0` | Mod 1 kamera mesafesi |
| `xai_tp_close_height` | `24.0` | `-24.0 - 96.0` | Mod 1 kamera yüksekliği |
| `xai_tp_far_distance` | `176.0` | `40.0 - 320.0` | Mod 2 kamera mesafesi |
| `xai_tp_far_height` | `36.0` | `-24.0 - 96.0` | Mod 2 kamera yüksekliği |
| `xai_tp_rear_distance` | `88.0` | `40.0 - 320.0` | Mod 3 kamera mesafesi |
| `xai_tp_rear_height` | `24.0` | `-24.0 - 96.0` | Mod 3 kamera yüksekliği |
| `xai_tp_padding` | `12.0` | `2.0 - 32.0` | Duvar çarpışması tamponu |

### CVAR Clamp Sistemi

Plugin yalnızca CVAR değerini okumakla kalmaz; gerçek kamera güncellemesinden önce güvenli çalışma aralıklarına sınırlar.

Örneğin:

```text
distance < 40.0  → 40.0
distance > 320.0 → 320.0
```

ve:

```text
height < -24.0  → -24.0
height > 96.0  → 96.0
```

Duvar tamponu için:

```text
padding < 2.0  → 2.0
padding > 32.0 → 32.0
```

uygulanır.

Bu nedenle `server.cfg` içinde aşırı değerler verilse bile kamera hesaplaması kontrolsüz şekilde sınırsızlaşmaz.

---

## 🛠️ Örnek `server.cfg`

```cfg
xai_tp_close_distance "88.0"
xai_tp_close_height "24.0"

xai_tp_far_distance "176.0"
xai_tp_far_height "36.0"

xai_tp_rear_distance "88.0"
xai_tp_rear_height "24.0"

xai_tp_padding "12.0"
```

---

## 📁 Otomatik Config Yükleme

Plugin başlangıcında aşağıdaki dosya otomatik olarak çalıştırılır:

```text
addons/XAI-EKLENTISI/ozellikler/thirdperson.cfg
```

Bu nedenle özel ayarları burada toplamak isteyen sunucular bu dosyayı kullanabilir.

Örnek:

```cfg
// addons/XAI-EKLENTISI/ozellikler/thirdperson.cfg

xai_tp_close_distance "78.0"
xai_tp_close_height "22.0"

xai_tp_far_distance "150.0"
xai_tp_far_height "34.0"

xai_tp_rear_distance "84.0"
xai_tp_rear_height "22.0"

xai_tp_padding "10.0"
```

Ayarları `server.cfg` üzerinden de yönetebilirsiniz.

---

## 🧠 Teknik Çalışma Mantığı

Kamera sistemi her aktif üçüncü şahıs oyuncu için bir `info_target` entity oluşturur.

Kamera entity'si:

```text
classname  = xai_tp_cam
movetype   = MOVETYPE_NONE
solid      = SOLID_NOT
owner      = player
```

olarak yapılandırılır.

Daha sonra:

```text
attach_view(player, camera)
```

ile oyuncunun görünümü kamera entity'sine bağlanır.

Gerçek zamanlı kamera güncellemesinde:

1. Oyuncunun `origin` bilgisi alınır.
2. `view_ofs` ile göz konumu hesaplanır.
3. `v_angle` üzerinden yön vektörü oluşturulur.
4. Aktif moda göre kamera yönü belirlenir.
5. Mesafe ve yükseklik CVAR'lardan okunur.
6. Hedef kamera konumu hesaplanır.
7. `TraceLine` ile engel kontrolü yapılır.
8. Çarpışma varsa padding uygulanır.
9. Kamera entity'si yeni konuma taşınır.
10. Kamera açıları güncellenir.

---

## 🎬 Modların Teknik Perspektifleri

### Mode 1 — Close Shoulder

Kamera oyuncunun arkasına yerleştirilir.

```text
Distance = xai_tp_close_distance
Height   = xai_tp_close_height
```

Varsayılan:

```text
88 / 24
```

---

### Mode 2 — Tactical

Aynı temel arka kamera mantığını daha uzak mesafeden kullanır.

```text
Distance = xai_tp_far_distance
Height   = xai_tp_far_height
```

Varsayılan:

```text
176 / 36
```

---

### Mode 3 — Cinematic Front

Kamera oyuncunun ön tarafına yerleştirilir.

Kamera açısı:

- yatay eksende `180°` terslenir,
- pitch terslenir,

ve böylece oyuncuya doğru bakan sinematik ön görünüm elde edilir.

```text
Distance = xai_tp_rear_distance
Height   = xai_tp_rear_height
```

Varsayılan:

```text
88 / 24
```

---

## 🔒 Client-Friendly / No Slowhack

Bu plugin client tarafına zorunlu config değişikliği uygulamaz.

Kod içinde:

```text
client_cmd(...)
```

ve oyuncunun `config.cfg` dosyasına zorunlu bind yazan bir mekanizma kullanılmaz.

F1 bind'i README'de yalnızca öneri olarak verilir.

---

## 📦 Harici Asset Gereksinimi

Bu plugin kamera sistemi için harici bir kamera modeli, sprite veya ses paketi gerektirmez.

Kamera entity'si runtime sırasında oluşturulur.

Kaynak kodda oyuncunun modeli kamera entity'sine aktarılabilse de entity:

```text
EF_NODRAW
```

ile gizlenir.

Dolayısıyla kamera özelliğini çalıştırmak için ayrıca model paketi göndermeniz gerekmez.

---

## 📋 Kurulum

### Hazır `.amxx` kullanımı

1. Aşağıdaki dosyayı alın:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx
```

2. Plugin klasörüne kopyalayın:

```text
addons/amxmodx/plugins/
```

3. Şurayı açın:

```text
addons/amxmodx/configs/plugins.ini
```

4. Şu satırı ekleyin:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx
```

5. İsteğe bağlı özel ayar dosyanızı oluşturun:

```text
addons/XAI-EKLENTISI/ozellikler/thirdperson.cfg
```

6. Haritayı değiştirin veya sunucuyu yeniden başlatın.

---

## 🧰 Kaynaktan Derleme

Kaynak dosya:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.sma
```

Derleme sırasında kullanılan include'lar:

```pawn
#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <xs>
```

Dolayısıyla derleme ortamınızda gerekli AMX Mod X include dosyalarının bulunması gerekir.

Runtime tarafında plugin:

```text
engine
fakemeta
```

API'lerine ihtiyaç duyar.

---

## 🔌 Plugin Bağımlılıkları

### Zorunlu

```text
AMX Mod X
engine
fakemeta
```

### Opsiyonel

```text
xai_main_menu
```

`xai_main_menu` mevcutsa otomatik menü entegrasyonu gerçekleştirilir.

Mevcut değilse plugin bağımsız olarak çalışır.

---

## 🧪 Kullanım Senaryosu

Sunucuya girdikten sonra:

```text
/tp
```

yazın.

İlk kullanım:

```text
Mode 1
```

İkinci kullanım:

```text
Mode 2
```

Üçüncü kullanım:

```text
Mode 3
```

Dördüncü kullanım:

```text
Mode 0 / First Person
```

---

## 📣 Oyuncu Bilgilendirmesi

Oyuncu sunucuya bağlandıktan kısa süre sonra konsoluna kamera sistemi hakkında bilgilendirme yazılır.

Bilgilendirmede:

```text
/tp
xai_thirdperson
bind F1 xai_thirdperson
```

kullanımları açıklanır.

Ayrıca chat üzerinden kamera sisteminin aktif olduğu bildirilir.

---

## ⚠️ Bilinmesi Gerekenler

### Kamera yalnızca canlı oyuncular için aktif görünür

Kamera modu seçili olsa dahi oyuncu ölü durumdaysa kamera kaldırılır.

### Geçerli olmayan mod

Aşağıdaki kullanım geçerli değildir:

```text
xai_tp_mode 4
```

Bu durumda plugin modu:

```text
0
```

olarak düzeltir.

### Kamera mesafesi sınırsız değildir

CVAR ile daha yüksek bir sayı girilmiş olsa bile runtime clamp nedeniyle gerçek maksimum mesafe:

```text
320.0
```

olacaktır.

### Duvar koruması TraceLine tabanlıdır

Bu sistem gerçek zamanlı çizgi tabanlı çarpışma kontrolüdür; fiziksel kamera gövdesinin tüm köşe durumlarını kapsayan tam hacimsel collision sistemi olarak değerlendirilmemelidir.

---

## 🗂️ Repository Yapısı

Bu repository şu temel dosyaları içerir:

```text
GoldSrc-Advanced-Thirdperson/
├── LICENSE
├── README.md
├── XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx
└── XAI-GoldSrc-Advanced-Thirdperson-Plugin.sma
```

---

## 📝 Plugin Bilgisi

```text
Plugin Name : XAI Advanced 3-Mode Third Person
Version     : 2.2.1
Author      : @xansuz
Engine      : GoldSrc
Platform    : AMX Mod X
```

---

## 🔗 Bağlantılar

**GitHub Repository:**  
https://github.com/xansuz/GoldSrc-Advanced-Thirdperson

**Developer:**  
https://github.com/xansuz

**AMX Mod X:**  
https://www.amxmodx.org/

---

# 🇬🇧 English

## 📖 Overview

**XAI Advanced 3-Mode Third Person Camera** is an AMX Mod X plugin for GoldSrc servers that provides three independent third-person camera perspectives with per-player state management and real-time wall collision resolution.

### Core capabilities

- Per-player camera state.
- Three third-person perspectives.
- First-person fallback mode.
- Real-time `TraceLine` collision checking.
- Camera position correction near geometry.
- Automatic camera cleanup on death.
- Automatic camera recreation after spawn.
- Camera cleanup on disconnect.
- Optional `xai_main_menu` integration.
- Standalone operation when `xai_main_menu` is unavailable.
- No forced client configuration changes.
- No external camera assets required.

---

## 🎥 Camera Modes

| Mode | Name | Description |
| :---: | :--- | :--- |
| `0` | First Person | Normal first-person view / camera disabled |
| `1` | Close Shoulder | Close third-person shoulder view |
| `2` | Tactical | Wider and farther tactical third-person view |
| `3` | Cinematic Front | Front-facing cinematic perspective with 180° reversed camera orientation |

---

## 🎮 Commands

### Cycle camera

```text
xai_thirdperson
```

Cycle order:

```text
0 → 1 → 2 → 3 → 0
```

### XAI aliases

```text
xai tp
xai thirdperson
```

### Direct mode selection

```text
xai_tp_mode <0-3>
```

Examples:

```text
xai_tp_mode 0
xai_tp_mode 1
xai_tp_mode 2
xai_tp_mode 3
```

Invalid values are normalized to:

```text
0
```

---

## 💬 Chat Commands

```text
/tp
!tp
/thirdperson
```

Team chat also supports:

```text
/tp
```

---

## ⌨️ Recommended Bind

```text
bind F1 xai_thirdperson
```

The plugin does **not** force client-side binds and does not modify the player's configuration automatically.

---

## ⚙️ CVAR Reference

| CVAR | Default | Runtime Range | Description |
| :--- | ---: | ---: | :--- |
| `xai_tp_close_distance` | `88.0` | `40.0 - 320.0` | Mode 1 distance |
| `xai_tp_close_height` | `24.0` | `-24.0 - 96.0` | Mode 1 height |
| `xai_tp_far_distance` | `176.0` | `40.0 - 320.0` | Mode 2 distance |
| `xai_tp_far_height` | `36.0` | `-24.0 - 96.0` | Mode 2 height |
| `xai_tp_rear_distance` | `88.0` | `40.0 - 320.0` | Mode 3 distance |
| `xai_tp_rear_height` | `24.0` | `-24.0 - 96.0` | Mode 3 height |
| `xai_tp_padding` | `12.0` | `2.0 - 32.0` | Wall collision padding |

The plugin clamps these values at runtime to keep camera calculations within supported boundaries.

---

## 🧱 Wall Collision

The camera calculates its desired position from the player's eye position and then performs a real-time `TraceLine`.

When geometry blocks the desired camera location:

```text
Trace hit
   ↓
Read trace end position
   ↓
Apply padding
   ↓
Move camera to resolved position
```

This reduces camera clipping through map geometry.

> The implementation is a `TraceLine`-based solution, not a full volumetric swept-hull camera collision system.

---

## 🧩 Optional XAI Main Menu Integration

When `xai_main_menu` is available, the plugin automatically registers:

```text
Third Person Kamera [F1 / 3 Mod]
```

with:

```text
xai_thirdperson
```

When the main menu plugin is unavailable, the camera plugin continues in standalone mode.

---

## 📁 Automatic Configuration

At startup the plugin executes:

```text
addons/XAI-EKLENTISI/ozellikler/thirdperson.cfg
```

You can place persistent camera CVAR overrides there.

Example:

```cfg
xai_tp_close_distance "78.0"
xai_tp_close_height "22.0"

xai_tp_far_distance "150.0"
xai_tp_far_height "34.0"

xai_tp_rear_distance "84.0"
xai_tp_rear_height "22.0"

xai_tp_padding "10.0"
```

---

## 📦 Installation

1. Copy:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx
```

to:

```text
addons/amxmodx/plugins/
```

2. Add:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx
```

to:

```text
addons/amxmodx/configs/plugins.ini
```

3. Optionally create:

```text
addons/XAI-EKLENTISI/ozellikler/thirdperson.cfg
```

4. Change the map or restart the server.

---

## 🧰 Source Compilation

Source:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.sma
```

Includes used by the plugin:

```pawn
#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <xs>
```

The runtime implementation uses the GoldSrc/AMX Mod X `engine` and `fakemeta` interfaces.

---

# 🇷🇺 Русский

## 📖 Обзор

**XAI Advanced 3-Mode Third Person Camera** — плагин AMX Mod X для GoldSrc, предоставляющий три режима камеры от третьего лица с независимым состоянием для каждого игрока.

### Возможности

- Индивидуальный режим камеры для каждого игрока.
- 3 режима Third Person.
- Возврат к виду от первого лица.
- Реальная проверка столкновений через `TraceLine`.
- Коррекция камеры возле стен и препятствий.
- Очистка камеры после смерти.
- Повторное создание камеры после возрождения.
- Очистка camera entity при отключении игрока.
- Автоматическая интеграция с `xai_main_menu`.
- Автономная работа без `xai_main_menu`.
- Без принудительного изменения клиентского `config.cfg`.
- Без дополнительных camera-моделей или ресурсов.

---

## 🎥 Режимы

| Режим | Название | Описание |
| :---: | :--- | :--- |
| `0` | First Person | Обычный вид от первого лица |
| `1` | Close Shoulder | Ближний вид из-за плеча |
| `2` | Tactical | Дальний тактический обзор |
| `3` | Cinematic Front | Фронтальная кинематографическая камера |

---

## 🎮 Команды

```text
xai_thirdperson
xai tp
xai thirdperson
```

Прямой выбор:

```text
xai_tp_mode <0-3>
```

Chat:

```text
/tp
!tp
/thirdperson
```

Рекомендуемый bind:

```text
bind F1 xai_thirdperson
```

---

## ⚙️ CVAR

| CVAR | По умолчанию | Runtime Range | Описание |
| :--- | ---: | :---: | :--- |
| `xai_tp_close_distance` | `88.0` | `40.0 - 320.0` | Дистанция режима 1 |
| `xai_tp_close_height` | `24.0` | `-24.0 - 96.0` | Высота режима 1 |
| `xai_tp_far_distance` | `176.0` | `40.0 - 320.0` | Дистанция режима 2 |
| `xai_tp_far_height` | `36.0` | `-24.0 - 96.0` | Высота режима 2 |
| `xai_tp_rear_distance` | `88.0` | `40.0 - 320.0` | Дистанция режима 3 |
| `xai_tp_rear_height` | `24.0` | `-24.0 - 96.0` | Высота режима 3 |
| `xai_tp_padding` | `12.0` | `2.0 - 32.0` | Буфер от стен |

---

## 📦 Установка

Скопируйте:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx
```

в:

```text
addons/amxmodx/plugins/
```

и добавьте:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx
```

в:

```text
addons/amxmodx/configs/plugins.ini
```

Дополнительные настройки:

```text
addons/XAI-EKLENTISI/ozellikler/thirdperson.cfg
```

После установки смените карту или перезапустите сервер.

---

# 🇷🇴 Română

## 📖 Prezentare

**XAI Advanced 3-Mode Third Person Camera** este un plugin AMX Mod X pentru GoldSrc care oferă trei perspective Third Person independente pentru fiecare jucător.

### Caracteristici

- Stare separată a camerei pentru fiecare jucător.
- 3 moduri de cameră.
- Revenire la First Person.
- Verificare de coliziune prin `TraceLine`.
- Corecție dinamică a poziției camerei lângă pereți.
- Eliminarea camerei la moarte.
- Reaplicarea modului după respawn.
- Curățarea entity-ului la disconnect.
- Integrare automată cu `xai_main_menu`.
- Funcționare standalone.
- Fără modificarea forțată a `config.cfg`.
- Fără resurse externe necesare.

---

## 🎥 Moduri

| Mod | Nume | Descriere |
| :---: | :--- | :--- |
| `0` | First Person | Vizualizarea normală |
| `1` | Close Shoulder | Perspectivă apropiată din spatele umărului |
| `2` | Tactical | Perspectivă mai îndepărtată |
| `3` | Cinematic Front | Perspectivă frontală cinematică |

---

## 🎮 Comenzi

```text
xai_thirdperson
xai tp
xai thirdperson
```

Selectare directă:

```text
xai_tp_mode <0-3>
```

Chat:

```text
/tp
!tp
/thirdperson
```

Bind recomandat:

```text
bind F1 xai_thirdperson
```

---

## ⚙️ CVAR-uri

| CVAR | Implicit | Interval runtime | Descriere |
| :--- | ---: | :---: | :--- |
| `xai_tp_close_distance` | `88.0` | `40.0 - 320.0` | Distanța modului 1 |
| `xai_tp_close_height` | `24.0` | `-24.0 - 96.0` | Înălțimea modului 1 |
| `xai_tp_far_distance` | `176.0` | `40.0 - 320.0` | Distanța modului 2 |
| `xai_tp_far_height` | `36.0` | `-24.0 - 96.0` | Înălțimea modului 2 |
| `xai_tp_rear_distance` | `88.0` | `40.0 - 320.0` | Distanța modului 3 |
| `xai_tp_rear_height` | `24.0` | `-24.0 - 96.0` | Înălțimea modului 3 |
| `xai_tp_padding` | `12.0` | `2.0 - 32.0` | Distanța tampon față de pereți |

---

## 📦 Instalare

Copiați:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx
```

în:

```text
addons/amxmodx/plugins/
```

Apoi adăugați:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx
```

în:

```text
addons/amxmodx/configs/plugins.ini
```

Configurația opțională:

```text
addons/XAI-EKLENTISI/ozellikler/thirdperson.cfg
```

Schimbați harta sau reporniți serverul.

---

# 🇫🇷 Français

## 📖 Présentation

**XAI Advanced 3-Mode Third Person Camera** est un plugin AMX Mod X pour GoldSrc qui fournit trois perspectives Third Person indépendantes pour chaque joueur.

### Fonctionnalités

- État de caméra indépendant par joueur.
- 3 modes Third Person.
- Retour à la vue First Person.
- Détection de géométrie avec `TraceLine`.
- Correction automatique de la position de la caméra près des murs.
- Nettoyage de la caméra lors de la mort.
- Réapplication après respawn.
- Nettoyage lors de la déconnexion.
- Intégration automatique avec `xai_main_menu`.
- Mode autonome sans menu principal.
- Aucun changement forcé de `config.cfg`.
- Aucun modèle de caméra externe requis.

---

## 🎥 Modes de caméra

| Mode | Nom | Description |
| :---: | :--- | :--- |
| `0` | First Person | Vue normale à la première personne |
| `1` | Close Shoulder | Vue rapprochée depuis l'épaule |
| `2` | Tactical | Vue tactique plus éloignée |
| `3` | Cinematic Front | Vue frontale cinématique inversée de 180° |

---

## 🎮 Commandes

```text
xai_thirdperson
xai tp
xai thirdperson
```

Sélection directe:

```text
xai_tp_mode <0-3>
```

Chat:

```text
/tp
!tp
/thirdperson
```

Bind recommandé:

```text
bind F1 xai_thirdperson
```

---

## ⚙️ CVAR

| CVAR | Par défaut | Plage runtime | Description |
| :--- | ---: | :---: | :--- |
| `xai_tp_close_distance` | `88.0` | `40.0 - 320.0` | Distance du Mode 1 |
| `xai_tp_close_height` | `24.0` | `-24.0 - 96.0` | Hauteur du Mode 1 |
| `xai_tp_far_distance` | `176.0` | `40.0 - 320.0` | Distance du Mode 2 |
| `xai_tp_far_height` | `36.0` | `-24.0 - 96.0` | Hauteur du Mode 2 |
| `xai_tp_rear_distance` | `88.0` | `40.0 - 320.0` | Distance du Mode 3 |
| `xai_tp_rear_height` | `24.0` | `-24.0 - 96.0` | Hauteur du Mode 3 |
| `xai_tp_padding` | `12.0` | `2.0 - 32.0` | Tampon de collision des murs |

---

## 📦 Installation

Placez:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx
```

dans:

```text
addons/amxmodx/plugins/
```

Puis ajoutez:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx
```

dans:

```text
addons/amxmodx/configs/plugins.ini
```

Configuration personnalisée:

```text
addons/XAI-EKLENTISI/ozellikler/thirdperson.cfg
```

Enfin, changez de carte ou redémarrez le serveur.

---

# 📜 License / Lisans

This project is distributed under the **MIT License**.

```text
MIT License

Copyright (c) 2026 xansuz
```

See the full license text in:

```text
LICENSE
```

---

# 👤 Credits

**Developer:** [@xansuz](https://github.com/xansuz)

**Project:** XAI Advanced 3-Mode Third Person Camera

**Repository:**  
https://github.com/xansuz/GoldSrc-Advanced-Thirdperson

---

# ⭐ Project Notes

This plugin is designed as a modular XAI component rather than a replacement for the entire server framework.

The third-person feature can be used:

```text
Standalone
```

or:

```text
Integrated with xai_main_menu
```

without requiring the main menu plugin to be present.

The camera system intentionally keeps its own state, CVARs, commands and camera entity lifecycle, allowing it to remain an independently deployable GoldSrc plugin.

---

