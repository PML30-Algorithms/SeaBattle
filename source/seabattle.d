module main;

import std.stdio;
import std.algorithm;
import std.math;
import std.random;



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


struct Board
{
  char [ROWS][COLS] hits;
  char [ROWS][COLS] ships;
}
immutable int BOARD_X = 50;
immutable int BOARD_Y = 50;

immutable int CELL_X = 50;
immutable int CELL_Y = 50;

immutable int ROWS = 10;
immutable int COLS = 10;


immutable int DIRS = 4;
immutable char player = 'X';
immutable int [DIRS] Drow=[0,+1,+1,+1];
immutable int [DIRS] Dcol=[+1,+1,0,-1];


immutable int MAX_X = 1000;
immutable int MAX_Y = 1000;

ALLEGRO_DISPLAY * display;
ALLEGRO_EVENT_QUEUE * event_queue;
ALLEGRO_FONT * global_font;

void init ()
{
	enforce (al_init ());
	enforce (al_init_primitives_addon ());
	enforce (al_install_mouse ());
	al_init_font_addon ();
	enforce (al_init_ttf_addon ());

	display = al_create_display (MAX_X, MAX_Y);
	enforce (display);

	event_queue = al_create_event_queue ();
	enforce (event_queue);

	global_font = al_load_ttf_font ("CONSOLA.TTF", 24, 0);

	al_register_event_source (event_queue, al_get_mouse_event_source ());
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
	int row, col;
	row = uniform(0,ROWS);
	col = uniform(0,COLS);

   board.ships[row][col] = 'O';
}


void draw (const ref Board board)
{
	al_clear_to_color (al_map_rgb_f (128,128,128));
	for (int row = 0; row < ROWS; row++)
        for (int col = 0; col < COLS; col++)
            drawCell (board,row, col, board.hits[row][col], board.ships[row][col]);
	al_flip_display ();
}

void drawCell (const ref Board board,int row, int col, char hits, char ships)
{
    int curx = BOARD_X + col * CELL_X;
    int cury = BOARD_Y + row * CELL_Y;

    al_draw_rectangle(curx-1,cury-1,curx + CELL_X-1,cury + CELL_Y-1, al_map_rgb_f(0,255,255),2.5);
    if (ships == 'O' && hits == 'X')
        al_draw_circle(curx +25, cury +25, 17.5, al_map_rgb_f(0,153,0),5);
    if (hits == 'X')
    {
        al_draw_line(curx+10,cury + 10, curx + 40, cury +40, al_map_rgb_f(0,0,153),5);
        al_draw_line(curx+10,cury + 40, curx + 40, cury +10, al_map_rgb_f(0,0,153),5);
    }

}

bool is_finished;

void moveHuman (ref Board board, char player)
{
    bool local_finished = false;
    while (!local_finished)
    {
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

            case ALLEGRO_EVENT_MOUSE_BUTTON_UP:
                int x = current_event.mouse.x;
                int y = current_event.mouse.y;
                if (moveMouse (board, player, x, y))
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
    moveHuman (board, 'X');
}



void main_loop ()
{

    Board board;
    initBoard (board);
    is_finished = false;




	while (true)
	{
	    draw (board);
	    moveX (board);
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



bool moveMouse (ref Board board, char player, int x, int y)
{
    if (x < BOARD_X || BOARD_X + ROWS *CELL_X <= x)
        return false;
    if (y < BOARD_Y|| BOARD_Y+ COLS *CELL_Y <= y)
        return false;
    int row = (y - BOARD_Y) / CELL_Y;
    int col = (x - BOARD_X) / CELL_X;
    if (board.hits[row][col] != '.')
        return false;
    board.hits[row][col] = player;

    if (wins (board, player))
    {
        writeln ("Player wins");
        is_finished = true;
        return true;
    }

    return true;
}



bool wins (Board board, char player)
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
