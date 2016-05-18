module source.kodukov;

import std.stdio;
import std.algorithm;
import std.math;
import std.random;
import std.conv;
import std.random;


import source.seabattle;

class Sashok : Player
{
    int count = 0;
    override Board battleMove()
    {
        int shots = myBoard.MaxShots ();
        for (int row = 0; row < ROWS; row++)
            for (int col = 0; col < COLS; col++)
            {
                 if(enemyBoard.ships[row][col] == 'O' && enemyBoard.hits[row][col] == 'X')
                 {
                     for (int drow = -1; drow <= +1; drow++)
                     {
                         for (int dcol = -1; dcol <= +1; dcol++)
                         {
                             if (0 <= row + drow && row + drow < ROWS &&
                                 0 <= col + dcol && col + dcol < COLS &&
                                 abs (drow) + abs (dcol) == 1)
                             {
                                 if (enemyBoard.hits[row + drow][col + dcol] != 'X')
                                 {
                                     enemyBoard.hits[row + drow][col + dcol] = 'Y';
                                     shots--;
                                     if (shots == 0)
                                     return enemyBoard;
                                 }


                             }
                             else
                             {
                                 for(int u = 0; u < myBoard.MaxShots (); u++)
                                 {
                                     int xbam = uniform(0, 9);
                                     int ybam = uniform(0, 9);
                                     if (enemyBoard.hits[xbam][ybam] != 'X' && enemyBoard.hits[xbam][ybam] != 'Y')
                                        enemyBoard.hits[xbam][ybam] = 'Y';
                                     else
                                     {
                                        xbam = uniform(0, 9);
                                        ybam = uniform(0, 9);
                                        u--;
                                     }
                                 }
                             }
                         }
                     }
                 }
            }
        return enemyBoard;
    }


    override Board prepareMove()
    {
        initBoard (myBoard);
        initBoard (enemyBoard);
        int coin = uniform(1, 5);
        if (coin == 1)
        {
           for (int p = 9; p > 5; p--)
                myBoard.ships[1][p] = 'O';
           for (int m = 9; m > 6; m--)
           {
               myBoard.ships[3][m] = 'O';
               myBoard.ships[5][m] = 'O';
           }
           for (int n = 9; n > 7; n--)
           {
               myBoard.ships[n][7] = 'O';
               myBoard.ships[n][9] = 'O';
               myBoard.ships[5][n] = 'O';
           }
           int q1 = uniform(0, 9);
           int q2 = uniform(0, 3);
           for (int a = 0; a < 4; a++)
             if (myBoard.hits[q1][q2] != 'O')
             {
                 myBoard.ships[q1][q2] = 'O';
                 q1 = uniform(0, 9);
                 q2 = uniform(0, 3);
             }
             else
             {
                 q1 = uniform(0, 9);
                 q2 = uniform(0, 3);
                 a--;
             }

        }
        if (coin == 2)
        {
           for (int p = 9; p > 5; p--)
                myBoard.ships[p][1] = 'O';
           for (int m = 9; m > 6; m--)
           {
               myBoard.ships[m][3] = 'O';
               myBoard.ships[m][5] = 'O';
           }
           for (int n = 9; n > 7; n--)
           {
               myBoard.ships[7][n] = 'O';
               myBoard.ships[9][n] = 'O';
               myBoard.ships[n][5] = 'O';

           }
           int q1 = uniform(0, 3);
           int q2 = uniform(0, 9);
           for (int a = 0; a < 4; a++)
             if (myBoard.ships[q1][q2] != 'O')
             {
                 myBoard.ships[q1][q2] = 'O';
                 q1 = uniform(0, 3);
                 q2 = uniform(0, 9);
             }
             else
             {
                 q1 = uniform(0, 3);
                 q2 = uniform(0, 9);
                 a--;
             }
        }
        if (coin == 3)
        {
           for (int p = 0; p < 4; p++)
                myBoard.ships[p][1] = 'O';
           for (int m = 0; m < 3; m++)
           {
               myBoard.ships[m][3] = 'O';
               myBoard.ships[m][5] = 'O';
           }
           for (int n = 0; n < 2; n++)
           {
               myBoard.ships[7][n] = 'O';
               myBoard.ships[9][n] = 'O';
               myBoard.ships[n][5] = 'O';

           }
           int q1 = uniform(6, 9);
           int q2 = uniform(0, 9);
           for (int a = 0; a < 4; a++)
             if (myBoard.ships[q1][q2] != 'O')
             {
                 myBoard.ships[q1][q2] = 'O';
                 q1 = uniform(6, 9);
                 q2 = uniform(0, 9);
             }
             else
             {
                 q1 = uniform(6, 9);
                 q2 = uniform(0, 9);
                 a--;
             }
        }
        if (coin == 4)
        {
           for (int p = 0; p < 4; p++)
                myBoard.ships[0][p] = 'O';
           for (int m = 0; m < 3; m++)
           {
               myBoard.ships[3][m] = 'O';
               myBoard.ships[5][m] = 'O';
           }
           for (int z = 0; z < 2; z++)
           {
               myBoard.ships[3][z] = 'O';
               myBoard.ships[5][z] = 'O';
               myBoard.ships[z][5] = 'O';
           }
           for (int n = 0; n < 1; n++)
           {
               myBoard.ships[n][7] = 'O';
               myBoard.ships[n][9] = 'O';
               int q1 = uniform(0, 9);
               int q2 = uniform(5, 9);
               for (int a = 0; a < 4; a++)
                 if (myBoard.ships[q1][q2] != 'O')
                 {
                    myBoard.ships[q1][q2] = 'O';
                    q1 = uniform(0, 9);
                    q2 = uniform(5, 9);
                 }
                 else
                 {
                     q1 = uniform(0, 9);
                     q2 = uniform(5, 9);
                     a--;
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
}
