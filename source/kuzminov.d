module source.kuzminov;

import std.stdio;
import std.algorithm;
import std.math;
import std.range;
import std.conv;
import std.random;
import std.typecons;

immutable int DIRS = 4;
immutable int [DIRS] Drow=[ 0, +1,  0, -1];
immutable int [DIRS] Dcol=[+1,  0, -1,  0];

import source.seabattle;

class ArtemIntelligence : Player
{
    int curRow,curCol;
    int turn = 0;


    alias Coord = Tuple!(int, "row", int, "col");


    override Board battleMove()
    {
        int shots = myBoard.MaxShots();
        turn++;
        Coord [] c;
        for (int row = 0; row < ROWS; row++)
            for (int col = 0; col < COLS; col ++)
                if (enemyBoard.hits[row][col] == 'X' && enemyBoard.ships[row][col] == 'O')
                    c ~= Coord(row,col);
        writeln(c);
        foreach (cell; c)
            {
                curRow = cell.row;
                curCol = cell.col;
                for (int d = 0; d < DIRS && shots > 0;d++)
                {
                    if (curRow + Drow[d] < ROWS && curRow + Drow[d] >= 0 && curCol + Dcol[d] < COLS && curCol + Dcol[d] >= 0)
                    {
                        if (enemyBoard.hits[curRow+Drow[d]][curCol+Dcol[d]] == '.')
                        {
                            enemyBoard.hits[curRow+Drow[d]][curCol+Dcol[d]] = 'Y';
                            shots--;
                        }
                    }
                }
            }

        {
            if( shots > 0)
            {
                if (turn == 1)
                {
                    enemyBoard.hits[0][0] = 'Y';
                    enemyBoard.hits[ROWS-1][0] = 'Y';
                    enemyBoard.hits[0][COLS-1] = 'Y';
                    enemyBoard.hits[ROWS-1][COLS -1 ] = 'Y';
                    writeln(":)");

                }
                else
                {
                    for (int  loop = shots ;loop > 0;loop--)
                    {
                    curRow = uniform(0, ROWS);
                    curCol = uniform(0, COLS);
                    writeln("hello:)");
                    if (enemyBoard.hits[curRow][curCol] != 'X' && enemyBoard.hits[curRow][curCol] != 'Y')
                        enemyBoard.hits[curRow][curCol] = 'Y';
                    else
                        loop++;

                    }
                }
            }
        }
        return enemyBoard;    }

    void get_ship(ref Board board, int sum) {
        int col, row;
        do {
            if (uniform(0, 2))
                col = 0;
            else
                col = 9;
            if (uniform(0, 2))
                row = 0;
            else
                row = 9;
        } while (board.ships[row][col] == 'O');

        if (uniform(0, 2)) {
            if (row == 9) {
                for (int i = 10 - sum; i < 10; i++) {
                    board.ships[i][col] = 'O';
                }
            }
            else {
                for (int i = 0; i < sum; i++) {
                    board.ships[i][col] = 'O';
                }
            }

        }
        else {
             if (col == 9) {
                for (int i = 10 - sum; i < 10; i++)
                    board.ships[row][i] = 'O';
            }
            else {
                for (int i = 0; i < sum; i++)
                    board.ships[row][i] = 'O';
            }
        }

    }

    override Board prepareMove()
    {
        initBoard (myBoard);
        initBoard (enemyBoard);

        get_ship(myBoard, 4);
        get_ship(myBoard, 3);
        get_ship(myBoard, 3);

        for (int len = 1; len < 3; len++)
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

};
