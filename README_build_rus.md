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

3. Клонируйте репозиторий OfrontPlus:

Сделайте это в подкаталоге `data/bin` так, чтобы
появился каталог `FreeOberon/data/bin/OfrontPlus` .
```
cd data/bin
git clone https://github.com/Oleg-N-Cher/OfrontPlus.git
```

4. Соберите OfrontPlus:

```
cd OfrontPlus/Target/Linux_amd64/Bin
./build
```

5. Соберите Free Oberon:

```
cd ../../../../../../..
cd FreeOberon/src
./make.sh
```

6. Запустите FreeOberon.

Делайте это из каталога, в котором находится исполнимый файл `FreeOberon`.

Примечания:

1. В будущем Free Oberon будет использовать Allegro5 вместо SDL2.
2. При сохранении файла в Free Oberon, убедитесь, что вводимое вами название файла не содержит в своём начале `../`.
