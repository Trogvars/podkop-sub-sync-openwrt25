# CHANGES

История изменений **Podkop Subscription Sync**.

Версии 24.x и 25.x развиваются синхронно по функциональности. Различия между ветками касаются прежде всего пакетного менеджера, формата пакета и особенностей OpenWrt.

## 1.3.1

### Исправлено

- Добавлен отсутствовавший bootstrap `install.sh` для OpenWrt 25.x.
- Команда вида:

```sh
wget -qO- https://raw.githubusercontent.com/Trogvars/podkop-sub-sync-openwrt25/main/install.sh | sh
```

  теперь работает так же, как в ветке OpenWrt 24.x.
- `install.sh` скачивает текущий `main`, запускает `install-podkop-sub-sync.sh` и передаёт ему все параметры (`--max-nodes`, `--include`, `--exclude`, `--with-xhttp` и т.д.).
- README переведён на единый bootstrap URL.

---

## 1.3.0

### Добавлено

- Новый глобальный UCI-параметр ограничения числа рабочих нод после precheck:

```text
option precheck_max_nodes '20'
```

- Значение `0` означает unlimited.
- Новый параметр installer-а:

```sh
--max-nodes 20
```

- Precheck теперь сохраняет latency каждой рабочей ноды.
- После полного теста ноды сортируются по времени ответа, и в рабочий набор попадают только X самых быстрых.
- В итоговый лог добавлены `Selected`, `Fastest` и `Cutoff`.
- После выбора Top X итоговые URI сортируются стабильно перед SHA256, чтобы изменение только порядка latency не вызывало лишний restart Podkop.

### Изменено

- `precheck_min_nodes` и `precheck_min_percent` проверяются **до** ограничения Top X.
- Для новых установок дефолт `precheck_max_nodes=20`.
- Если параметр отсутствует в старом конфиге, используется `0`, то есть прежнее поведение без ограничения.
- User-Agent обновлён до ветки 1.3.
- README и bundle обновлены.

### Зачем

Даже если subscription даёт десятки рабочих серверов, нет необходимости держать их все в URLTest. Новый лимит позволяет полностью протестировать subscription, но передавать в Podkop/sing-box только самые быстрые ноды.

---

## 1.2.0

### Добавлено

- Новый UCI-параметр whitelist по странам:

```text
list include_country 'RU'
```

- Поддержка нескольких разрешённых стран:

```text
list include_country 'RU'
list include_country 'KZ'
```

  В этом случае сохраняются ноды RU **или** KZ.

- Новый параметр installer-а:

```sh
--include RU
```

  Параметр можно указывать несколько раз.

- Фильтрация стран теперь выполняется в порядке:

```text
protocols -> XHTTP -> include_country -> exclude_country -> precheck
```

- Если страна одновременно присутствует в `include_country` и `exclude_country`, **exclude имеет приоритет**.
- При активном whitelist ноды без подходящего emoji-флага страны удаляются.
- Добавлена явная ошибка, если whitelist удалил все proxy.
- README дополнен примером отдельного RU-only конфига.
- В шапку README добавлены перекрёстные ссылки на проекты OpenWrt 24.x и 25.x.
- Bundle `podkop-sub-sync-bundle.tar.gz` пересобран с новой логикой.

### Совместимость

Старые конфиги продолжают работать без изменений: `include_country` начинает влиять на фильтрацию только после явного добавления параметра.

---

## 1.1.0

### Добавлено

- Поддержка XHTTP-сценария с `sing-box-extended`.
- Новый параметр installer-а:

```sh
--with-xhttp
```

- Installer умеет:
  - проверить, что активен `sing-box-extended`;
  - при необходимости запустить installer `EikeiDev/OpenWRT-sing-box-extended`;
  - проверить XHTTP parser в Podkop;
  - при необходимости применить `moix89/podkop-xhttp-patch`;
  - включить `allow_xhttp=1`.

- В updater добавлена ранняя защита:
  - `allow_xhttp=1` + обычный sing-box -> понятная ошибка;
  - `allow_xhttp=1` + отсутствие `xhttp)` в Podkop facade -> понятная ошибка.

- Ошибка определяется до скачивания subscription и массового precheck.
- README дополнен ручной и автоматической установкой XHTTP-зависимостей.
- Исправлены ссылки после переименования репозитория в `podkop-sub-sync-openwrt25`.

### Изменено

- Основная ветка остаётся рассчитанной на OpenWrt 25.x и `apk`.
- Bundle пересобран с актуальным installer и README.

---

## 1.0.0

Первая полноценная версия ветки для OpenWrt 25.x.

### Основные возможности

- OpenWrt 25.x / `apk`.
- Monolithic installer `install-podkop-sub-sync.sh`.
- Скачивание VPN subscription.
- Поддержка:
  - plain text;
  - Base64;
  - gzip;
  - Base64 + gzip.
- Поддерживаемые proxy-ссылки:
  - VLESS;
  - Trojan;
  - Shadowsocks.
- Включение/отключение отдельных протоколов.
- Фильтрация XHTTP.
- Blacklist стран через:

```text
list exclude_country 'RU'
```

- Реальный proxy precheck через временный sing-box.
- Batch processing для ограничения потребления RAM.
- Контрольный HTTP URL и ожидаемый HTTP-код.
- Safety thresholds по минимальному количеству и проценту рабочих нод.
- SHA256 итогового рабочего списка.
- Отсутствие лишнего restart Podkop, если список не изменился.
- Автоматическое обновление Podkop URLTest.
- `sing-box check` после генерации Podkop config.
- Rollback при невалидном новом конфиге.
- `procd` service + daemon.
- Повтор после ошибки через `retry_interval`.
