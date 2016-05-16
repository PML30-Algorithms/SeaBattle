module source.kuzminov;

import std.stdio;
import std.algorithm;
import std.math;
import std.random;
import std.conv;
import std.random;


import source.seabattle;

class kuzminov : Player
{
    int curRow,curCol;

    override Board battleMove()
    {
        bool blood = false;
        int srow,scol;


            for (int d=0;d<myBoard.MaxShots(); d++)
                if (enemyBoard.hits[curRow +Drow[d]][curCol + Dcol[d]]!= 'X')
                    enemyBoard.hits[curRow +Drow[d]][curCol + Dcol[d]] = 'Y';
            for (int row = 0;row  < ROWS; row++)
                for ( int col = 0; col < COLS; col ++)
                    if ( enemyBoard.hits [row][col] == 'Y' )
                        enemyBoard.hits[row][col] = 'X';



        void main_shoot (ref Board enemyBoard, int MaxShots)
        {
            int shots;
            while( blood == false )
            {

                if (enemyBoard.hits[curRow][curCol] == 'X' && enemyBoard.ships[curRow][curCol] == 'O')
                {
                        blood = true;
                        break;
                }
                while (shots < myBoard.MaxShots())
                {
                        srow = uniform(0, ROWS);
                        scol = uniform(0, COLS);
                        shots++;
                }
                curRow++;
                curCol++;
            }
            if (blood == true)
            {
                for (int d=0;d<MaxShots; d++)
                if (enemyBoard.hits[curRow +Drow[d]][curCol + Dcol[d]]!= 'X')
                    enemyBoard.hits[curRow +Drow[d]][curCol + Dcol[d]] = 'Y';
                for (int row = 0;row  < ROWS; row++)
                    for ( int col = 0; col < COLS; col ++)
                        if ( enemyBoard.hits [row][col] == 'Y' )
                            enemyBoard.hits[row][col] = 'X';
                blood = false;
            }
        }




        return enemyBoard;
    }

    void get_ship(ref Board board, int sum) {


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
