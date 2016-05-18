module source.seabattle;

import std.stdio;
import std.algorithm;
import std.math;
import std.random;
import std.conv;
import std.random;


import std.datetime;
import std.concurrency;
import std.range;
import std.typecons;
import core.stdc.stdlib;
import std.exception;
import std.socket;
import std.stdio;
import std.string;
pragma (lib, "dallegro5");
pragma (lib, "allegro");

pragma (lib, "allegro_primitives");

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.allegro_font;
import allegro5.allegro_ttf;


import source.kazmenko;
import source.kodukov;
import source.kuzminov;
import source.nefedov;
import source.new_super_player;
import source.razuvaev;


abstract class Player
{
    Board myBoard;
    Board enemyBoard;

    Board battleMove();
    Board prepareMove();
    void updateEnemyMove (Board newMyBoard);
    void updateMyMove (Board newEnemyBoard);

}

class HumanPlayer : Player
{
    void moveHuman (alias moveMouse, alias moveKeyboard) (ref Board board, int boardX, int boardY)
    {
        bool local_finished = false;
        while (!local_finished)
        {
            draw ();

            ALLEGRO_EVENT current_event;
            al_wait_for_event (event_queue, &current_event);

            switch (current_event.type)
            {
                case ALLEGRO_EVENT_DISPLAY_CLOSE:
                    happy_end ();
                    break;

                case ALLEGRO_EVENT_DISPLAY_SWITCH_IN:
                    draw ();
                    break;

                case ALLEGRO_EVENT_KEY_DOWN:

                    int keycode = current_event.keyboard.keycode;

                    if (moveKeyboard (board, keycode, myBoard.MaxShots()))
                    {
                        local_finished = true;
                    }
                    break;

                case ALLEGRO_EVENT_MOUSE_BUTTON_UP:

                    int x = current_event.mouse.x;
                    int y = current_event.mouse.y;

                    if (moveMouse (board, boardX, boardY, x, y, myBoard.MaxShots()))
                    {
                        local_finished = true;
                    }
                    break;

                default:
                    break;
            }
        }
    }

    void draw ()
    {
        myBoard.drawAllShips = true;
        enemyBoard.drawAllShips = false;

        al_clear_to_color (al_map_rgb_f (128,128,128));
        drawBoard (myBoard, MY_BOARD_X, MY_BOARD_Y);
        drawBoard (enemyBoard, ENEMY_BOARD_X, ENEMY_BOARD_Y);
        drawShips (myBoard,MY_BOARD_X, MY_BOARD_Y, ROWS, COLS);
        finishButton.draw ();
        al_flip_display ();

    }

    override Board battleMove()
    {
        draw ();
        moveHuman !(moveMouseBattle, moveKeyboardBattle) (enemyBoard, ENEMY_BOARD_X, ENEMY_BOARD_Y);
        draw ();
        return enemyBoard;
    }

    override Board prepareMove()
    {
        initBoard (myBoard);
        initBoard (enemyBoard);

        myBoard.ships[0][0] = 'O';
        myBoard.ships[0][1] = 'O';
        myBoard.ships[0][2] = 'O';
        myBoard.ships[0][3] = 'O';

        myBoard.ships[2][0] = 'O';
        myBoard.ships[2][1] = 'O';
        myBoard.ships[2][2] = 'O';

        myBoard.ships[3][4] = 'O';
        myBoard.ships[3][5] = 'O';
        myBoard.ships[3][6] = 'O';

        myBoard.ships[8][0] = 'O';
        myBoard.ships[9][0] = 'O';

        myBoard.ships[8][3] = 'O';
        myBoard.ships[9][3] = 'O';

        myBoard.ships[8][9] = 'O';
        myBoard.ships[9][9] = 'O';

        myBoard.ships[5][5] = 'O';

        myBoard.ships[5][9] = 'O';

        myBoard.ships[6][1] = 'O';

        myBoard.ships[7][7] = 'O';

        draw ();
        moveHuman !(moveMousePrepare, moveKeyboardPrepare) (myBoard, MY_BOARD_X, MY_BOARD_Y);
        draw ();
        return myBoard;
    }

    override void updateEnemyMove (Board newMyBoard)
    {
        myBoard = newMyBoard;
        if(wins_player(myBoard))
        {
            if(wins_player(enemyBoard))
                writeln("Mirror =|");
            else
                writeln("Lose =(");
        }
        else
        {
            if(wins_player(enemyBoard))
                writeln("Win =)");
        }

        draw ();
    }

    override void updateMyMove (Board newEnemyBoard)
    {
        enemyBoard = newEnemyBoard;
        draw ();
    }
}

bool valid (ref Board board, int row, int col)
{
    if (row < 10 && col < 10 && row >= 0 && col >= 0)
    {
        if (board.ships[row][col] != 'O')
          return true;
        else
          return false;
    }
    else
        return true;
}

class ComputerPlayer : Player
{
    int curRow;
    int curCol;

    override Board battleMove()
    {
        int shots = 0;
        while (shots < myBoard.MaxShots())
        {
            do
            {
                    curRow = uniform(0, ROWS);
                    curCol = uniform(0, COLS);
            }
            while ( enemyBoard.hits[curRow][curCol] == 'X');
            enemyBoard.hits[curRow][curCol] = 'Y';
            shots++;
        }


        return enemyBoard;
    }

    override Board prepareMove()
    {
        initBoard (myBoard);
        initBoard (enemyBoard);
        for (int len = 1; len <= MAX_LEN; len++)
              for (int num = 1; num <= 5 - len; num++)
              {
                  int rrow = uniform(0, 10);
                  int rcol = uniform(0, 10);
                  int rdir = uniform(0, 2);

                  if (rdir == 0)
                  {
                     bool flag1 = true;
                     if (rrow + len - 1 >= 10)
                     {
                        rrow = uniform(0, 10);
                        num--;
                        continue;
                     }
                     if (valid(myBoard, rrow - 1, rcol) && valid(myBoard, rrow + len, rcol))
                        flag1 = true;
                     else
                        flag1 = false;



                     for (int k = 0; k < len; k++)
                        if(!valid (myBoard, rrow + k, rcol + 1) || !valid (myBoard, rrow + k, rcol - 1) ||
                           !valid (myBoard, rrow + k, rcol))
                            flag1 = false;
                     if(flag1 == true)
                         for(int t = 0; t < len; t++)
                         {
                            myBoard.ships[rrow + t][rcol] = 'O';
                         }

                     else
                     {
                        rrow = uniform(0, 10);
                        num--;
                     }

                  }
                  else
                  {
                      if (rcol + len - 1 >= 10)
                      {
                          rcol = uniform(0, 10);
                          num--;
                          continue;
                      }
                      bool flag2 = true;
                      if (valid(myBoard, rrow, rcol - 1) && valid(myBoard, rrow, rcol + len))
                        flag2 = true;
                      else
                        flag2 = false;
                      for (int k = 0; k < len; k++)
                        if(!valid (myBoard, rrow + 1, rcol + k) || !valid (myBoard, rrow - 1, rcol + k) ||
                           !valid (myBoard, rrow, rcol + k))
                              flag2 = false;
                      if(flag2 == true)
                         for(int t = 0; t < len; t++)
                         {
                            myBoard.ships[rrow ][rcol + t] = 'O';
                         }



                      else
                      {
                        rcol = uniform(0, 10);
                        num--;
                      }
                  }
               }

        curRow = 0;
        curCol = 0;
        assert (finishPrepareMove (myBoard));
        return myBoard;
    }

    override void updateEnemyMove (Board newMyBoard)
    {
        myBoard = newMyBoard;
    }

    override void updateMyMove (Board newEnemyBoard)
    {
        enemyBoard = newEnemyBoard;
     }
}

class RemoteNetworkPlayer : Player
{
    Socket socket;

    this (Socket listeningSocket)
    {
        socket = listeningSocket.accept ();
    }

    ~this ()
    {
        socket.shutdown (SocketShutdown.BOTH);
        socket.close ();
    }

    override Board battleMove()
    {
        enemyBoard = receiveBoard (socket);
        return enemyBoard;
    }

    override Board prepareMove()
    {
        initBoard (myBoard);
        initBoard (enemyBoard);
        myBoard = receiveBoard (socket);
        return myBoard;
    }

    override void updateEnemyMove (Board newMyBoard)
    {
        myBoard = newMyBoard;
        sendBoard (socket, myBoard);
    }

    override void updateMyMove (Board newEnemyBoard)
    {
        enemyBoard = newEnemyBoard;
        sendBoard (socket, enemyBoard);
    }
}

class Server
{
    bool gameOver (Board [2] board)
    {
        if (wins (board[1]) && wins (board[0]))
        {
            writeln("Draw");
            return true;
        }
        if (wins (board[1]))
        {
            writeln ("Player1 wins");
            return true;
        }
        if (wins (board[0]))
        {
            writeln ("Player2 wins");
            return true;
        }


        return false;

    }

    bool processPrepareMove (ref Board board, const Board newBoard)
    {
        board = newBoard;
        return finishPrepareMove (board);
    }

    bool processBattleMove (ref Board board, const ref Board newBoard, int MaxShots)
    {
        if (finishBattleMove (newBoard, MaxShots))
        {
            foreach (row; 0..ROWS)
                foreach (col; 0..COLS)
                    if (newBoard.hits[row][col] == 'Y')
                        board.hits[row][col] = 'X';
            return true;
        }
        return false;
    }

    Board makeSecretBoard(const ref Board board)
    {

        Board secretBoard = board;
        foreach(row;0..ROWS)
            foreach(col;0..COLS)
                if (board.ships[row][col] == 'O' && board.hits[row][col] != 'X')
                    secretBoard.ships[row][col] = '.';
        return secretBoard;
    }

    void play( Player [2] player )
    {
        stdout.flush ();
        Board [2] board;
        foreach (num ;0..2)
            if (!processPrepareMove (board[num], player[num].prepareMove ()))
                return;
        int savenum = board[1].MaxShots();
        while (!gameOver(board))
        {
            foreach (num ;0..2)
            {
                auto newBoard = player[num].battleMove();
                if (num == 1) {
                        if (!processBattleMove (board[!num], newBoard, savenum))
                            return;
                }
                else
                if (!processBattleMove (board[!num], newBoard, board[num].MaxShots ()))
                    return;
            }

            foreach (num;0..2)
            {
                player[num].updateMyMove (makeSecretBoard (board[!num]));
                player[num].updateEnemyMove (board[num]);
            }
        }
    }
}


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
  int [MAX_LEN+1] actual_ships;
  bool drawAllShips;
  char [ROWS][COLS] light;

    string toString () const
    {
        string res;
        foreach (row; 0..ROWS)
            res ~= hits[row];
        foreach (row; 0..ROWS)
            res ~= ships[row];
        return res;
    }

    int MaxShots()
    {
        int cntship=0;
        int maxshots = 1;
        int countershots = 1;
        int saverow,savecol = 0;
        foreach ( row; 0..ROWS)
            foreach (col; 0.. COLS)
            {
                cntship =0;
                if (ships[row][col] == 'O')
                {
                    for (int d=0;d<DIRS; d++)
                    {
                        cntship = 0;
                        saverow = row;
                        savecol = col;
                        bool flag = false;
                        while (saverow < ROWS && savecol < COLS)
                        {
                            if (ships[saverow][savecol] == 'O')
                            {
                                cntship++;
                            }
                            else break;
                            if (hits[saverow][savecol] != 'X')
                                flag = true;

                            saverow += Drow[d];
                            savecol += Dcol[d];
                        }
                        if (flag && cntship > maxshots)
                            maxshots = cntship;

                    }

                }
            }
        return maxshots;
    }
}

Board toBoard (const (char) [] s)
{
    Board res;
    foreach (row; 0..ROWS)
        foreach (col; 0..COLS)
        {
            res.hits[row][col] = s[0];
            s = s[1..$];
        }
    foreach (row; 0..ROWS)
        foreach (col; 0..COLS)
        {
            res.ships[row][col] = s[0];
            s = s[1..$];
        }
    return res;
}

immutable int MY_BOARD_X = 50;
immutable int MY_BOARD_Y = 50;

immutable int ENEMY_BOARD_X = 550;
immutable int ENEMY_BOARD_Y = 50;

immutable int CELL_X = 40;
immutable int CELL_Y = 40;

immutable int ROWS = 10;
immutable int COLS = 10;


immutable int DIRS = 2;

immutable int [DIRS] Drow=[0,+1];
immutable int [DIRS] Dcol=[+1,0];

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

void drawBoard (const ref Board board, int boardX, int boardY)
{
    for (int row = 0; row < ROWS; row++)
        for (int col = 0; col < COLS; col++)
            drawCell (board, boardX, boardY, row, col, board.hits[row][col], board.ships[row][col], board.light[row][col]);
}



void drawCell (const ref Board board, int boardX, int boardY, int row, int col, char hits, char ships, char light)
{
    int curx = boardX + col * CELL_X;
    int cury = boardY + row * CELL_Y;

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

void drawShips (const ref Board board, int boardX, int boardY, int row, int col)
{
    int curx = boardX + col * CELL_X;
    int cury = boardY + row * CELL_Y;
    al_draw_filled_rectangle (CELL_X,13*CELL_Y,CELL_X*2,14*CELL_Y,  al_map_rgb_f(0.5, 0.2, 0.77) );
    al_draw_text(global_font,al_map_rgb_f(1.0, 1.0, 1.0) , CELL_X, CELL_Y*15,0,"4");
    al_draw_filled_rectangle (CELL_X*3,13*CELL_Y,CELL_X *5,14*CELL_Y,  al_map_rgb_f(0.5, 0.2, 0.77) );
    al_draw_text(global_font,al_map_rgb_f(1.0, 1.0, 1.0) , CELL_X*3, CELL_Y*15,0,"3");
    al_draw_filled_rectangle (CELL_X*6,13*CELL_Y,CELL_X *9,14*CELL_Y,  al_map_rgb_f(0.5, 0.2, 0.77) );
    al_draw_text(global_font,al_map_rgb_f(1.0, 1.0, 1.0) , CELL_X*6, CELL_Y*15,0,"2");
    al_draw_filled_rectangle (CELL_X*10,13*CELL_Y,CELL_X *14,14*CELL_Y,  al_map_rgb_f(0.5, 0.2, 0.77) );
    al_draw_text(global_font,al_map_rgb_f(1.0, 1.0, 1.0) , CELL_X*10, CELL_Y*15,0,"1");

    al_draw_textf(global_font,al_map_rgb_f(0.7, 0.6, 0.2) , CELL_X, CELL_Y*16,0, "%d", board.actual_ships[1]);
    al_draw_textf(global_font,al_map_rgb_f(0.7, 0.6, 0.3) , CELL_X*3, CELL_Y*16,0, "%d",board.actual_ships[2]);
    al_draw_textf(global_font,al_map_rgb_f(0.7, 0.6, 0.4) , CELL_X*6, CELL_Y*16,0, "%d",board.actual_ships[3]);
    al_draw_textf(global_font,al_map_rgb_f(0.7, 0.6, 0.5) , CELL_X*10, CELL_Y*16,0, "%d",board.actual_ships[4]);
}

void sendBoard (Socket socket, Board board)
{
    debug {writeln ("send start"); stdout.flush ();}
    auto s = board.toString ();
    int left = 0;
    while (left < 200)
    {
        int len = socket.send (s);
        debug {writeln ("send actual ", len); stdout.flush ();}
        left += len;
        s = s[len..$];
    }
    assert (left == 200);
    debug {writeln ("send finish ", left); stdout.flush ();}
}

Board receiveBoard (Socket socket)
{
    debug {writeln ("receive start ", socket.handle ()); stdout.flush ();}
    static char [] [socket_t] buf;
    static int [socket_t] left;
    auto handle = socket.handle ();
    if (handle !in buf)
    {
        buf[handle] = new char [1024];
        left[handle] = 0;
    }
    while (left[handle] < 200)
    {
        int len = socket.receive (buf[handle][left[handle]..$]);
        debug {writeln ("receive actual ", len); stdout.flush ();}
        left[handle] += len;
    }
    auto res = buf[handle][0..200].dup;
    for (int i = 200; i < left[handle]; i++)
        buf[handle][i - 200] = buf[handle][i];
    left[handle] -= 200;
    debug {writeln ("receive finish ", left[handle]); stdout.flush ();}
    return toBoard (res);
}

void main_loop (string [] args)
{
    finishButton = new Button (200, 700, 100, 30,
                               al_map_rgb_f (1.0, 0.0, 0.0), al_map_rgb_f (1.0, 1.0, 1.0), "End Turn");


    string IP = "127.0.0.1";
    if (args.length > 2)
    {
        IP = args[2];
    }
    ushort PORT_NUMBER = 80;
    if (args.length > 3)
    {
        PORT_NUMBER = to!ushort(args[3]);
    }

    if (args.length > 1 && args[1] == "-server")
    {
        auto address = parseAddress (IP, PORT_NUMBER);
        auto socket = new TcpSocket ();
        socket.setOption (SocketOptionLevel.TCP, SocketOption.TCP_NODELAY, true);
        socket.bind (address);
        socket.listen (1);
        Player remoteNetworkPlayer0 = new RemoteNetworkPlayer (socket);
        Player remoteNetworkPlayer1 = new RemoteNetworkPlayer (socket);
        Server server = new Server ();
        server.play ([remoteNetworkPlayer0, remoteNetworkPlayer1]);
    }
    else if (args.length > 1 && args[1] == "-client")
    {
        auto address = parseAddress (IP, PORT_NUMBER);
        auto socket = new TcpSocket ();
        socket.setOption (SocketOptionLevel.TCP, SocketOption.TCP_NODELAY, true);
        socket.connect (address);

        Player humanPlayer = new HumanPlayer ();
        sendBoard (socket, humanPlayer.prepareMove ());
        while (true)
        {
            sendBoard (socket, humanPlayer.battleMove ());
            humanPlayer.updateMyMove (receiveBoard (socket));
            humanPlayer.updateEnemyMove (receiveBoard (socket));
        }
    }
    else
    {
        foreach (i; 0..1000)
        {
            Player humanPlayer = new ArtemIntelligence ();
            Player newPlayer = new AI0 ();
            Server server = new Server ();
            server.play ([humanPlayer, newPlayer]);
        }
    }

//    draw (board);
    while (true)
    {
        ALLEGRO_EVENT current_event;
        al_wait_for_event (event_queue, &current_event);

        switch (current_event.type)
        {
             case ALLEGRO_EVENT_DISPLAY_SWITCH_IN:
//                draw (board);
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
        main_loop (args);
        happy_end ();
        return 0;
    });
}

bool moveMouseBattle (ref Board board, int boardX, int boardY, int x, int y, int MaxShots)
{
    if (finishButton.inside (x, y))
    {
        return finishBattleMove (board, MaxShots);
    }

    if (x < boardX || boardX + ROWS *CELL_X <= x)
        return false;
    if (y < boardY || boardY + COLS *CELL_Y <= y)
        return false;
    int row = (y - boardY) / CELL_Y;
    int col = (x - boardX) / CELL_X;

    if (board.hits[row][col] == 'Y')   board.hits[row][col] = '.';
    else
        if (board.hits[row][col] == '.')   board.hits[row][col] = 'Y';


    return false;
}

bool finishBattleMove (const ref Board board, int MaxShots)
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

    return true;
}

bool moveKeyboardBattle (ref Board board, int keycode, int MaxShots)
{
    if (keycode == ALLEGRO_KEY_ENTER)
    {
        return finishBattleMove (board, MaxShots);
    }
    return false;
}

bool moveMousePrepare (ref Board board, int boardX, int boardY, int x, int y, int  MaxShots)
{
    if (finishButton.inside (x, y))
    {
        return finishPrepareMove (board);
    }

    if (x < boardX || boardX + ROWS *CELL_X <= x)
        return false;
    if (y < boardY || boardY + COLS *CELL_Y <= y)
        return false;
    int row = (y - boardY) / CELL_Y;
    int col = (x - boardX) / CELL_X;

    if (board.ships[row][col] == 'O') board.ships[row][col] = '.';
    else
      if (board.ships[row][col] == '.')  board.ships[row][col] = 'O';

    return false;
}

bool finishPrepareMove (ref Board board)
{
    for (int i = 1; i<MAX_LEN + 1;i++)
                board.actual_ships[i] = 0;
    for (int row = 0; row < ROWS; row++)
        for (int col= 0; col < COLS; col++)
        {
            board.light[row][col] = '-';
        }


    for (int row = 0; row < ROWS - 1; row++)
        for (int col= 0; col < COLS - 1; col++)
        {

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


    for (int row = 0; row < ROWS; row++)
    {
        for (int col = 0; col < COLS; col++)
            if (b[row][col])
            {
                b[row][col] = false;
                int count1 = 1, count2 = 1;
                for (int x = row + 1; x < ROWS; x++)
                    if(b[x][col])
                    {
                        count1++;
                        b[x][col] = false;

                    }
                    else break;
                for (int y = col + 1; y < COLS; y++)
                    if(b[row][y])
                    {
                        count2++;
                        b[row][y] = false;
                    }

                    else break;

                if (count1 == 1)
                    count1 = count2;
                if (count1 <= 4)
                {
                    board.actual_ships[count1]++;
                }

                else
                {
                    board.light[row][col] = '+';
                    for (int x = row + 1; x < ROWS; x++)
                        if(board.ships[x][col] == 'O')
                        {
                            board.light[x][col] = '+';
                        }
                        else break;
                    for (int y = col + 1; y < COLS; y++)
                        if(board.ships[row][y] == 'O')
                        {
                            board.light[row][y] = '+';
                        }
                        else break;

                    writeln ("Big ship");
                    return false;
                }
           }
    }

    foreach (len; 0..MAX_LEN + 1)
    {
        if (board.actual_ships[len] < NUM_SHIPS[len])
        {
            writeln("Number of ships of length ", len, " is ",
                    board.actual_ships[len], " instead of ", NUM_SHIPS[len]);
            return false;
        }
        else if(board.actual_ships[len] > NUM_SHIPS[len])
        {
            writeln("Number of ships of length ", len, " is ",
                    board.actual_ships[len], " instead of ", NUM_SHIPS[len]);

            foreach (row; 0..ROWS)
                foreach (col; 0..COLS)
                    b[row][col] = (board.ships[row][col] == 'O');


            for (int row = 0; row < ROWS; row++)
            {
                for (int col = 0; col < COLS; col++)
                {
                    if (b[row][col])
                    {
                        b[row][col] = false;
                        int count1 = 1, count2 = 1;
                        for (int x = row + 1; x < ROWS; x++)
                            if(b[x][col])
                            {
                                count1++;
                                b[x][col] = false;

                            }
                            else break;
                        for (int y = col + 1; y < COLS; y++)
                            if(b[row][y])
                            {
                                count2++;
                                b[row][y] = false;
                            }

                            else break;

                        if (count1 == 1)
                            count1 = count2;
                        if (count1 == len)
                        {
                            board.light[row][col] = '+';
                            for (int x = row + 1; x < ROWS; x++)
                                if(board.ships[x][col] == 'O')
                                {
                                    board.light[x][col] = '+';
                                }
                                else break;
                            for (int y = col + 1; y < COLS; y++)
                                if(board.ships[row][y] == 'O')
                                {
                                    board.light[row][y] = '+';
                                }
                                else break;
                        }
                    }
                }
            }

            return false;
        }
    }

    return true;
}




bool moveKeyboardPrepare (ref Board board, int keycode, int MaxShots)
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
            /*1000*/
            if (board.ships[row][col] == 'O' && board.hits[row][col] == '.')
                return false;
        }
    }


    return true;
}

bool wins_player (Board board)
{
    int total = 0;
    foreach (len, num; NUM_SHIPS[])
    {
        total += len * num;
    }
    int count = 0;
    for (int row = 0; row < ROWS; row++)
    {
        for (int col = 0; col < COLS; col++)
        {
            /*1000*/
            if (board.ships[row][col] == 'O' && board.hits[row][col] == 'X')
                count ++;
        }
    }
    return count == total;
}
