module main;

import std.stdio;
import std.algorithm;
import std.math;
import std.random;

immutable MaxShots = 4;

import std.datetime;
import std.concurrency;
import std.range;
import std.typecons;
import core.stdc.stdlib;
import std.exception;
import std.stdio;
import std.string;
pragma (lib, "dallegro5");
pragma (lib, "allegro");

pragma (lib, "allegro_primitives");

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.allegro_font;
import allegro5.allegro_ttf;

class Button
{
    int x,y,width,height;
    ALLEGRO_COLOR backgroundColor;
    ALLEGRO_COLOR nameColor;
    string name;

    this (int x_, int y_, int width_, int height_,
          ALLEGRO_COLOR backgroundColor_, ALLEGRO_COLOR nameColor_, string name_)
    {
        x = x_;
        y = y_;
        width = width_;
        height = height_;
        backgroundColor = backgroundColor_;
        nameColor = nameColor_;
        name = name_;
    }

    bool inside (int px, int py)
    {
        return (x<=px && px<=x+width && y<=py && py<=y+height);

    }

    void draw ()
    {

        al_draw_filled_rectangle(x,y,x+width,y+height, backgroundColor);
        al_draw_text (global_font, nameColor, x + width * 0.5, y + (height - FONT_HEIGHT) * 0.5,
                      ALLEGRO_ALIGN_CENTRE, name.toStringz);

    }
}

Button finishButton;

struct Board
{
  char [ROWS][COLS] hits;
  char [ROWS][COLS] ships;
  bool drawAllShips;
  char [ROWS][COLS] light;
}

immutable int BOARD_X = 50;
immutable int BOARD_Y = 50;

immutable int CELL_X = 40;
immutable int CELL_Y = 40;

immutable int ROWS = 10;
immutable int COLS = 10;


immutable int DIRS = 4;

immutable int [DIRS] Drow=[0,+1,+1,+1];
immutable int [DIRS] Dcol=[+1,+1,0,-1];

immutable int MAX_LEN = 4;
immutable int NUM_SHIPS [MAX_LEN + 1] = [0, 4, 3, 2, 1];

immutable int MAX_X = 1000;
immutable int MAX_Y = 1000;

immutable int FONT_HEIGHT = 24;

ALLEGRO_DISPLAY * display;
ALLEGRO_EVENT_QUEUE * event_queue;
ALLEGRO_FONT * global_font;

void init ()
{
    enforce (al_init ());
    enforce (al_init_primitives_addon ());
    enforce (al_install_mouse ());
    enforce (al_install_keyboard ());
    al_init_font_addon ();
    enforce (al_init_ttf_addon ());

    display = al_create_display (MAX_X, MAX_Y);
    enforce (display);

    event_queue = al_create_event_queue ();
    enforce (event_queue);

    global_font = al_load_ttf_font ("Inconsolata-Regular.ttf", FONT_HEIGHT, 0);

    al_register_event_source (event_queue, al_get_mouse_event_source ());
    al_register_event_source (event_queue, al_get_keyboard_event_source ());
    al_register_event_source (event_queue, al_get_display_event_source (display));
}


void initBoard (ref Board board)
{
    for (int row = 0; row < ROWS; row++)
    {
        for (int col = 0; col < COLS; col++)
        {
            board.hits[row][col] = '.';
        }
    }
    for (int row = 0; row < ROWS; row++)
    {
        for (int col = 0; col < COLS; col++)
        {
            board.ships[row][col] = '.';
        }
    }
    board.drawAllShips = false;
}


void draw (const ref Board board)
{
    al_clear_to_color (al_map_rgb_f (128,128,128));
    for (int row = 0; row < ROWS; row++)
        for (int col = 0; col < COLS; col++)
            drawCell (board, row, col, board.hits[row][col], board.ships[row][col], board.light[row][col]);
    finishButton.draw ();
    al_flip_display ();

}



void drawCell (const ref Board board, int row, int col, char hits, char ships, char light)
{
    int curx = BOARD_X + col * CELL_X;
    int cury = BOARD_Y + row * CELL_Y;

    double CELL_SCALE = min (CELL_X, CELL_Y);
    al_draw_rectangle(curx-1,cury-1,curx + CELL_X-1,cury + CELL_Y-1, al_map_rgb_f(0,255,255),0.05* CELL_SCALE);
    if (light == '+')
    {
        al_draw_filled_rectangle (curx, cury, curx + CELL_X, cury + CELL_Y,
                                          al_map_rgb_f (0.8, 0.3, 0.5));
    }
    if (ships == 'O' && (hits == 'X' || board.drawAllShips))
        al_draw_circle(curx + 0.5*CELL_X, cury + 0.5*CELL_Y, 0.375* CELL_SCALE, al_map_rgb_f(0,153,0),0.1* CELL_SCALE);
    if (hits == 'X')
    {
        al_draw_line(curx+ 0.2*CELL_X,cury + 0.2*CELL_Y, curx + 0.8*CELL_X, cury + 0.8*CELL_Y, al_map_rgb_f(0,0,153),0.1* CELL_SCALE);
        al_draw_line(curx+ 0.2*CELL_X,cury + 0.8*CELL_Y, curx + 0.8*CELL_X, cury + 0.2*CELL_Y, al_map_rgb_f(0,0,153),0.1* CELL_SCALE);
    }
    if (hits == 'Y')
    {
        al_draw_line(curx+ 0.2*CELL_X,cury + 0.2*CELL_Y, curx + 0.8*CELL_X, cury + 0.8*CELL_Y, al_map_rgb_f(153,0,0),0.1* CELL_SCALE);
        al_draw_line(curx+ 0.2*CELL_X,cury + 0.8*CELL_Y, curx + 0.8*CELL_X, cury + 0.2*CELL_Y, al_map_rgb_f(153,0,0),0.1* CELL_SCALE);
    }

}

bool is_finished;


void moveHuman (alias moveMouse, alias moveKeyboard) (ref Board board)
{
    bool local_finished = false;
    while (!local_finished)
    {
        draw (board);

        ALLEGRO_EVENT current_event;
        al_wait_for_event (event_queue, &current_event);

        switch (current_event.type)
        {
            case ALLEGRO_EVENT_DISPLAY_CLOSE:
                happy_end ();
                break;

            case ALLEGRO_EVENT_DISPLAY_SWITCH_IN:
                draw (board);
                break;

            case ALLEGRO_EVENT_KEY_DOWN:

                int keycode = current_event.keyboard.keycode;

                if (moveKeyboard (board, keycode))
                {
                    local_finished = true;
                }
                break;

            case ALLEGRO_EVENT_MOUSE_BUTTON_UP:

                int x = current_event.mouse.x;
                int y = current_event.mouse.y;

                if (moveMouse (board, x, y))
                {
                    local_finished = true;
                }
                break;

            default:
                break;
        }
    }
}

void moveX (ref Board board)
{
  moveHuman !(moveMouseBattle, moveKeyboardBattle) (board);
}

void main_loop ()
{
    finishButton = new Button (600, 200, 100, 30,
                               al_map_rgb_f (1.0, 0.0, 0.0), al_map_rgb_f (1.0, 1.0, 1.0), "FINISH");

    Board board;
    initBoard (board);
    is_finished = false;

    board.drawAllShips = true;
    draw (board);
    moveHuman !(moveMousePrepare, moveKeyboardPrepare) (board);
    board.drawAllShips = false;

    while (true)
    {
        draw (board);
        moveX (board);
        draw(board);
        if (wins (board))
        {
            writeln ("Player wins");
            is_finished = true;
        }
        if (is_finished) break;
    }
    draw (board);

    while (true)
    {
        ALLEGRO_EVENT current_event;
        al_wait_for_event (event_queue, &current_event);

        switch (current_event.type)
        {
             case ALLEGRO_EVENT_DISPLAY_SWITCH_IN:
                draw (board);
                break;

            case ALLEGRO_EVENT_DISPLAY_CLOSE:
                happy_end ();
                break;

            default:
                break;
        }
    }
}

void happy_end ()
{
    al_destroy_display (display);
    al_destroy_event_queue (event_queue);
    al_destroy_font (global_font);

    al_shutdown_ttf_addon ();
    al_shutdown_font_addon ();
    al_shutdown_primitives_addon ();

    exit (EXIT_SUCCESS);
}



int main (string [] args)
{

    return al_run_allegro (
    {
        init ();
        main_loop ();
        happy_end ();
        return 0;
    });
}




bool moveMouseBattle (ref Board board, int x, int y)
{
    if (finishButton.inside (x, y))
    {
        return finishBattleMove (board);
    }

    if (x < BOARD_X || BOARD_X + ROWS *CELL_X <= x)
        return false;
    if (y < BOARD_Y|| BOARD_Y+ COLS *CELL_Y <= y)
        return false;
    int row = (y - BOARD_Y) / CELL_Y;
    int col = (x - BOARD_X) / CELL_X;

    if (board.hits[row][col] == 'Y')   board.hits[row][col] = '.';
    else
        if (board.hits[row][col] == '.')   board.hits[row][col] = 'Y';


    return false;
}

bool finishBattleMove (ref Board board)
{
    int cnt = 0;
    foreach (row; 0..ROWS)
        foreach (col; 0..COLS)
        if (board.hits[row][col] == 'Y')
            cnt ++;

    if (cnt > MaxShots)
    {
        writeln("LESS SHIPS");
        return false;
    }

    if (cnt < 1)
    {
        writeln("MORE SHIPS");
        return false;
    }

    foreach (row; 0..ROWS)
        foreach (col; 0..COLS)
            if (board.hits[row][col] == 'Y')
                board.hits[row][col] = 'X';
    return true;
}

bool moveKeyboardBattle (ref Board board, int keycode)
{
    if (keycode == ALLEGRO_KEY_ENTER)
    {
        return finishBattleMove (board);
    }
    return false;
}

bool moveMousePrepare (ref Board board,  int x, int y)
{
    if (finishButton.inside (x, y))
    {
        return finishPrepareMove (board);
    }

    if (x < BOARD_X || BOARD_X + ROWS *CELL_X <= x)
        return false;
    if (y < BOARD_Y|| BOARD_Y+ COLS *CELL_Y <= y)
        return false;
    int row = (y - BOARD_Y) / CELL_Y;
    int col = (x - BOARD_X) / CELL_X;

    if (board.ships[row][col] == 'O') board.ships[row][col] = '.';
    else
      if (board.ships[row][col] == '.')  board.ships[row][col] = 'O';

    return false;
}

bool finishPrepareMove (ref Board board)
{
    for (int row = 0; row < ROWS; row++)
        for (int col= 0; col < COLS; col++)
        {
            board.light[row][col] = '-';
        }


    for (int row = 0; row < ROWS - 1; row++)
        for (int col= 0; col < COLS - 1; col++)
        {
            board.light[row][col] = '-';

            if ((board.ships[row][col] == 'O') + (board.ships[row + 1][col] == 'O') +
                (board.ships[row][col + 1] == 'O') + (board.ships[row + 1][col + 1] == 'O') >= 3)
              {
                  board.light[row][col] = '+';
                  board.light[row + 1][col] = '+';
                  board.light[row][col + 1] = '+';
                  board.light[row + 1][col + 1] = '+';

                  writeln("Your ships touch each other");
                  return false;
              }
        }
    bool [ROWS] [COLS] b;
    foreach (row; 0..ROWS)
        foreach (col; 0..COLS)
            b[row][col] = (board.ships[row][col] == 'O');

    int actual_ships [MAX_LEN + 1];
    for (int row = 0; row < ROWS; row++)
    {
        for (int col = 0; col < COLS; col++)
            if (b[row][col])
            {
                b[row][col] = false;
                int count1 = 1, count2 = 1;
                for (int z = row + 1; z < ROWS; z++)
                    if(b[z][col])
                    {
                        count1++;
                        b[z][col] = false;

                    }
                    else break;
                for (int y = col + 1; y < COLS; y++)
                    if(b[row][y])
                    {
                        count2++;
                        b[row][y] = false;

                    }

                    else break;

                for (int crow = 0; row < ROWS; row++)
                {

                    for (int ccol = 0; col < COLS; col++)
                            board.light[crow][ccol] = '-';
                }
                if (count1 == 1)
                    count1 = count2;
                if (count1 <= 4)
                {
                    actual_ships[count1]++;
                    board.light[row][col] = '+';
                }

                else
                {

                    board.light[row][col] = '+';
                    writeln ("Big ship");
                    return false;
                }
           }
    }
    foreach (len; 0..MAX_LEN + 1)
    {
        if (actual_ships[len] != NUM_SHIPS[len])
        {
            writeln("Number of ships of length ", len, " is ",
                    actual_ships[len], " instead of ", NUM_SHIPS[len]);
            return false;
        }
    }
    return true;
}

bool moveKeyboardPrepare (ref Board board, int keycode)
{
    if (keycode == ALLEGRO_KEY_ENTER)
    {
        return finishPrepareMove (board);
    }
    return false;
}




bool wins (Board board)
{
  for (int row = 0; row < ROWS; row++)
    {
        for (int col = 0; col < COLS; col++)
        {
            if (board.ships[row][col] == 'O' && board.hits[row][col] == '.')
                return false;
        }
    }


    return true;
}
