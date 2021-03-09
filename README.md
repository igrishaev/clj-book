# Книга «Clojure на производстве»

[Печатная версия](https://grishaev.me/clojure-in-prod/) | [PDF-бандл](https://gumroad.com/l/ZcEET)

![](https://user-images.githubusercontent.com/1059232/85860614-be75fd80-b7c7-11ea-8553-3bde8d14b576.jpg)

## Сборка образов

Зависимости:

- git
- make
- Docker

```bash
make docker-build-images
```

## Сборка книги


- Формат А5 без знаков издательства:

```bash
make docker-build-print
```


- Формат А5 для издательства:

```bash
make docker-build-ridero
```

- Широкий формат B5 для издательства:

```bash
make docker-build-ridero-large
```


- Читалка Kindle:

```bash
make docker-build-kindle
```


- Телефон:

```bash
make docker-build-phone
```


- Планшет:

```bash
make docker-build-tablet
```
