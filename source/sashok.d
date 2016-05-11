module source.sashok;

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
        int coin = uniform(1, 4);
        if (coin == 1)
        {
           for (int p = 9; p > 5; p--)
                myBoard.shipa[1][p] = 'O';
           for (int m = 9; m > 6; m--)
           {
               myBoard.shipa[3][m] = 'O';
               myBoard.shipa[5][m] = 'O';
           }
           for (int n = 9; n > 7; n--)
           {
               myBoard.shipa[n][7] = 'O';
               myBoard.shipa[n][9] = 'O';

           }
        }
        int q1 = uniform(0, 9);
        int q2 = uniform(0, 4);
        for (int a = 0; a < 3; a++)
          if (myBoard[q1][q2] != 'O')
          {
              myBoard[q1][q2] = 'O';
              q1 = uniform(0, 9);
              q2 = uniform(0, 4);
          }
          else
          {
              q1 = uniform(0, 9);
              q2 = uniform(0, 4);
              a--;
          }


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
