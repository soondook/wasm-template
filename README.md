# WASM Template — публикация на GitHub Pages

Короткое руководство как превратить этот Blazor WebAssembly проект в простой шаблон (skill) и публиковать его на GitHub Pages.

**Что делает добавленный workflow**
- Срабатывает на `push` в ветку `main`.
- Выполняет `dotnet restore` и `dotnet publish -c Release -o publish`.
- Автоматически правит `index.html` в `publish/wwwroot`, подставляя `/<repo>/` в `<base href="...">`.
- Деплоит содержимое `publish/wwwroot` в ветку `gh-pages` через `peaceiris/actions-gh-pages`.

**Требования (локально / в Actions)**
- .NET SDK 9.0 (проект таргетит `net9.0`).
- Для локальной проверки можно использовать `dotnet serve` (или `python -m http.server`).

Локальная сборка и тест (быстро):

1) Собрать релиз:

```bash
dotnet publish -c Release -o publish
```

2) Запустить локально (вариант A — dotnet-serve):

```bash
dotnet tool install --global dotnet-serve
dotnet serve -d publish/wwwroot -p 8080
# открыть http://localhost:8080/<repo>/  или http://localhost:8080/ (в зависимости от base href)
```

Вариант B — стандартный Python HTTP сервер:

```bash
cd publish/wwwroot
python -m http.server 8080
# открыть http://localhost:8080/
```

Примечания про `base href`:
- В `wwwroot/index.html` сейчас стоит `<base href="/" />`.
- Workflow автоматически заменяет это на `/<repository-name>/` (например, `/wasm-template/`) перед деплоем. Это корректно для project pages `https://<user>.github.io/<repo>/`.
- Если вы хотите публиковать как user/organization page (например, `username.github.io`), верните `<base href="/" />` или вручную отредактируйте `index.html`.

Как подготовить репозиторий и запустить деплой:

1) Создайте пустой репозиторий на GitHub (назовите, например, `wasm-template`).
2) Локально инициализируйте git (если ещё не) и добавьте remote:

```bash
git init
git remote add origin https://github.com/<your-user>/<your-repo>.git
git add .
git commit -m "Initial: add Blazor WASM template + GitHub Pages workflow"
git branch -M main
git push -u origin main
```

3) После пуша workflow запустится на GitHub Actions, соберёт проект и создаст/обновит ветку `gh-pages`.

4) Откройте настройки репозитория -> Pages и убедитесь, что источником выбрана ветка `gh-pages` (root). В большинстве случаев Pages автоматически активируется и будет доступен по `https://<your-user>.github.io/<your-repo>/`.

Проверка и отладка
- Посмотрите лог Actions (Actions -> workflow run) если деплой не прошёл.
- Если приложение загружается с ошибками — проверьте, что в `publish/wwwroot` присутствуют файлы `_framework`, dll и `blazor.webassembly.js`.

Готово — у вас есть минимальный reproducible workflow чтобы использовать этот проект как шаблон для следующих WASM-приложений.

Если хотите, могу:
- добавить автоматический тест (smoke check) после деплоя; или
- изменить workflow чтобы поддерживать публикацию в корень (user page) по флагу; или
- подготовить скрипт для ручной генерации ветки `gh-pages` локально.

Локальный скрипт деплоя
- В репозитории добавлен PowerShell-скрипт `scripts/deploy.ps1`, который выполняет:
	- `dotnet publish` -> `publish`;
	- замену `<base href>` в `publish/wwwroot/index.html` на `/<repo>/`;
	- копирует содержимое `publish/wwwroot` во временную папку, инициализирует там git и пушит в ветку `gh-pages` (force push).

Пример использования (PowerShell):
```powershell
# деплой на удалённый репозиторий (по умолчанию использован https://github.com/soondook/wasm-template.git)
.\scripts\deploy.ps1 -RemoteUrl 'https://github.com/soondook/wasm-template.git'

# подготовить, но не пушить (полезно для проверки)
.\scripts\deploy.ps1 -NoPush

# сборка + деплой + запуск локального сервера
.\scripts\deploy.ps1 -Serve
```
