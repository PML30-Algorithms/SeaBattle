### Идеальный план

#### Правила

Есть два игрока.
У каждого есть своя доска 10x10 с кораблями.
Игрок расставляет корабли на своей доске, а потом стреляет в чужую доску.
Цель --- первым уничтожить все корабли противника.

##### Первый этап

Каждый игрок расставляет свои корабли (один 1x4, два 1x3, три 1x2, четыре 1x1) на своей доске.
Корабли не могут перекрываться или касаться сторонами, но могут касаться углами.

##### Второй этап

Дальнейшая игра состоит из ходов.
Каждый ход проходит в два шага.
Каждый шаг происходит одновременно для обоих игроков.

На первом шаге игрок выбирает от 1 до k неповреждённых клеток, чтобы выстрелить в них.
Здесь k --- размер самого большого из оставшихся у игрока кораблей.

На втором шаге игроку сообщается, сколько было попаданий.

#### Возможности

* Выбор для каждого игрока: человек, компьютер.
* Выбор из нескольких искусственных интеллектов.
* Турнир для искусственных интеллектов (~10,000 партий).
* Возможность для искусственного интеллекта запоминать информацию между партиями.
* Возможность подключения игрока по сети.

### С чего можно начать

* Есть доска ROWS x COLS.
* На ней занята одна случайная клетка.
* Она выводится на экран.
* Мы тыкаем в доску мышкой.
* Если нашли клетку, это победа.
* Если нет, она помечается, и ищем дальше.
* Найденная клетка тоже помечена, как будто там стоял корабль.

### Дальше

* У нас есть один игрок.
* На первом этапе он расставляет корабли.
* Пока что расставляем один корабль 1x1, потом больше, но всё ещё 1x1.
* На втором этапе корабли не показываются, и он сам по ним стреляет.
* Пока что стреляем просто по одной клетке.
* Теперь эти два этапа можно делать по отдельности.

### Что готово 11.04.2016

* На первом этапе ставится один корабль 1x1, ничего не показывается.
* На втором этапе есть два шага.
* Первый шаг --- выбор любого числа клеток для выстрела мышкой (toggle клетки), Enter, чтобы закончить.
* Второй шаг --- выстрелы выполняются, проверяется условие победы: что все корабли покрыты выстрелами.

### Дальнейший план

#### Первый этап

* Ставится любое число кораблей 1x1, Enter, чтобы закончить.
* Режим рисования с отображением кораблей.
* Проверка количества кораблей 1x1 при клике (toggle клетки).
* Длинные корабли --- строить по одной клетке.
* Рисование сбоку нужного количества кораблей, отображение текущего количества.

#### Второй этап

* Проверка количества клеток для выстрела: сравнение с maxShots.

#### Остальное

* Константы: нужное количество кораблей.
* Рисование отдельно от доски кнопки Finish, дублирующей нажатие Enter.
* Два игрока вместо одного.
* Первый человек, второй компьютер, играющий пока случайно.

### Что готово 13.04.2016

* Общее: кнопка Finish (End Turn).
* Общее: состояние доски --- показывать ли корабли.
* Первый этап: проверяется расстановка кораблей --- количество, длина, касание.
* Первый этап: в консоль выводится, что стоит неправильно.
* Второй этап: выстрелов на каждом ходу не больше константы.

### Дальнейший план

#### Общее

* Количество кораблей в структуре Board.
* История ходов в структуре Board.
* Сообщения на экране вместо консоли.
* Два игрока.
* Разделение сущностей: игрок 1, игрок 2, сервер, интерфейс.

#### Первый этап

* Рисование сбоку поставленного и нужного количества кораблей.
* Подсветка неправильной расстановки (по реализации: квадраты 2x2, длины, количества).

#### Второй этап

* Количество выстрелов не больше максимальной длины своего корабля.
* Отображение истории ходов:
  * ходы разными цветами,
  * список ходов сбоку,
  * дробь вместо крестиков.

### Что готово 20.04.2016

#### Общее

* Есть два игрока.
* Один человек, другой компьютер.
* У каждого есть своя доска 10x10 с кораблями.
* Игрок расставляет корабли на своей доске, а потом стреляет в чужую доску.

#### Первый этап

* Каждый игрок расставляет свои корабли (один 1x4, два 1x3, три 1x2, четыре 1x1) на своей доске.
* Корабли не могут перекрываться или касаться сторонами, но могут касаться углами.

#### Второй этап

* На первом шаге игрок выбирает от 1 до k неповреждённых клеток, чтобы выстрелить в них.
* Пока что k = 4.
* На втором шаге игроку сообщается, сколько было попаданий.
* Пока что сообщается про каждую клетку отдельно.

### План на 25.04.2016

* (+ Артём, Дима) Взаимодействие по сети.
* (+ Саша) Первый этап: нарисовать снизу, сколько каких кораблей нужно.
* (+ Саша) Первый этап: подсвечивать снизу, сколько каких кораблей уже поставлено.
* (. Артём) Второй этап: сделать k = размер самого большого из оставшихся у игрока кораблей.
* (-) Второй этап: сообщать про все клетки выстрела вместе.
* (+ Саша) Конец игры: ничья.
* (-) Конец игры: проверка с информацией игрока, а не сервера.

### Возможный план на 04.05.2016

* Исправить [issue #24](https://github.com/PML30-Algorithms/SeaBattle/issues/24).
* Случайный искусственный интеллект.
* Тестирование ИИ:
  * человек-компьютер,
  * компьютер1-компьютер2 с визуализацией,
  * компьютер1-компьютер2 несколько партий.
