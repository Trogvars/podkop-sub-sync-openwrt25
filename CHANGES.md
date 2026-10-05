# CHANGES

## Legacy status

This repository is frozen at **1.3.2**. Development continues in the unified **Trogvars/podkop-sub-sync** project for OpenWrt 24.x and 25.x. The existing code and bundle remain unchanged as a legacy rollback/reference snapshot.

История изменений **Podkop Subscription Sync**.

Версии 24.x и 25.x развиваются синхронно по функциональности. Различия между ветками касаются прежде всего пакетного менеджера, формата пакета и особенностей OpenWrt.

## 1.3.2

### Добавлено

- Полностью автоматическая установка `sing-box-extended` при включённом XHTTP.
- Автоматическое восстановление Podkop XHTTP patch.
- Auto-heal XHTTP-зависимостей работает как в installer-е, так и внутри установленного `/usr/bin/podkop-sub-sync`.

### Изменено

- Убран обязательный интерактивный запуск SBE installer через `/dev/tty`.
- Автоматически выбирается первый стабильный релиз и рекомендуемый installer-ом формат для текущего роутера.
- При `allow_xhttp=1` updater восстанавливает зависимости до download/precheck и продолжает работу только после успешной проверки.
- User-Agent обновлён до `podkop-sub-sync/1.3.2`.

### Исправлено

- Исправлен сценарий, когда после обновления скриптов XHTTP был включён, но обычный sing-box оставался установленным, из-за чего updater сразу завершался ошибкой.

---

## 1.3.1

### Исправлено и улучшено

- `install.sh` теперь является универсальным bootstrap installer для обеих веток.
- Bootstrap автоматически читает версию OpenWrt из `/etc/openwrt_release`.
- Для `24.*` автоматически выбирается:

```text
Trogvars/podkop-sub-sync-openwrt24
install-openwrt24.sh
```

- Для `25.*` автоматически выбирается:

```text
Trogvars/podkop-sub-sync-openwrt25
install-podkop-sub-sync.sh
```

- Все аргументы (`--url`, `--interval`, `--max-nodes`, `--include`, `--exclude`, `--with-xhttp`, `--no-start`) передаются выбранному installer-у без изменений.
- Для неподдерживаемой версии OpenWrt bootstrap завершается с явной ошибкой.
- В ветке OpenWrt 25.x исправлено отсутствие `install.sh`, из-за которого `wget -qO- .../install.sh | sh` ранее завершался без видимого результата.
- README обеих веток обновлены под единый сценарий установки.

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
