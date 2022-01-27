# Как собрать новую версию Free Oberon под Линукс

Команды приведены для ОС Дебиан / Убунту.

## Вариант 1. Скачать архив и запустить установщик

1. На сайте https://github.com/kekcleader/FreeOberon.git
   нажмите зелёную кнопку «Code» и «Download ZIP»,
   распакуйте архив в домашнем каталоге.
   Вы можете переименовать каталог `FreeOberon-master` в `FreeOberon`.

2. Находясь в распакованном каталоге, запустите `install.sh` с правами администратора.
```
su
./install.sh
```

## Вариант 2. Собрать Free Oberon вручную

1. Установите Git, Gcc и Allegro5:
```
apt-get install -y liballegro5-dev git gcc
```

2. Клонируйте репозиторий Free Oberon:
```
git clone https://github.com/kekcleader/FreeOberon.git
```

3. Клонируйте репозиторий OfrontPlus с помощью команды загрузки подмодулей:

```
cd FreeOberon
git submodule update --init
```

Каталог `FreeOberon/Data/bin/OfrontPlus` заполнится файлами.

4. Соберите OfrontPlus:

```
cd Data/bin/OfrontPlus/Target/Linux_amd64/Bin
./build

cd ../../../../../../..
```

5. Соберите Free Oberon:

```
cd FreeOberon/src
./make.sh
```

6. Запустите FreeOberon.

Это делается из каталога, в котором находится исполнимый файл `FreeOberon`.
```
./FreeOberon
```

Документ обновлён 27 января 2022 года.
