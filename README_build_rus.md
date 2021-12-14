# Как собрать новую версию Free Oberon под Линукс

Команды приведены для ОС Дебиан / Убунту.

1. Установите git, gcc и SDL2:
```
apt-get install -y libsdl2-dev libsdl2-image-dev binutils git gcc
```

2. Клонируйте репозиторий Free Oberon:
```
git clone https://github.com/kekcleader/FreeOberon.git
```

3. Создайте подкаталог bin:
```
cd FreeOberon
mkdir bin
```

3. Клонируйте репозиторий OfrontPlus с помощью команды загрузки подмодулей:

```
git submodule update --init
```

Каталог `FreeOberon/data/bin/OfrontPlus` заполнится файлами.

4. Соберите OfrontPlus:

```
cd data/bin/OfrontPlus/Target/Linux_amd64/Bin
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

Примечания:

1. В будущем Free Oberon будет использовать Allegro5 вместо SDL2.
2. Имя файла должно совпадать с названием модуля и иметь
   расширение Mod (с заглавной буквы).


Документ обновлён 14 декабря 2021 года
