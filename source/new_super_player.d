module source.new_super_player;

import std.stdio;
import std.algorithm;
import std.math;
import std.random;
import std.conv;
import std.random;


import source.seabattle;

class NewSuperPlayer : Player
{
    int curRow = -1;
    int curCol = 4;
    int step = 0;
    int [] dirx = [-1, 0, 1, 0];
    int [] diry = [0, -1, 0, 1];


    bool correct(int x, int y) {
        if (x < 0 || y < 0)
            return false;
        if (x > 9 || y > 9)
            return false;
        if (enemyBoard.hits[x][y] == 'X')
            return false;
        if (enemyBoard.hits[x][y] == 'Y')
            return false;
        return true;
    }

    override Board battleMove()
    {
        int shots = 0;
        int flag2 = 0;
        while (shots < myBoard.MaxShots())
        {
            flag2++;
            bool success = false;
            for (int i = 0; i < ROWS; i++)
                for (int j = 0; j < COLS; j++)
                    if (enemyBoard.ships[i][j] == 'O' && enemyBoard.hits[i][j] == 'X' && !success) {
                        for (int q = 0; q < 4; q++) {
                            if (correct(i + dirx[q], j + diry[q])) {
                                enemyBoard.hits[i + dirx[q]][j + diry[q]] = 'Y';
                                shots++;
                                success = true;
                                break;
                            }
                        }
                    }

            if (success)
                continue;
            int flag = 0;
            if (step < 2) {
                curRow++;
                curCol--;
                if (curCol < 0 || curRow > 9) {
                    curCol += 5;
                    curRow--;
                    while (curRow > 0 && curCol < 9) {
                        curRow--;
                        curCol++;
                    }
                }
                if (curCol > 9) {
                    curRow = 0;
                    curCol = 1;
                    step++;
                }
            }
            if (step == 2) {
                do
                {
                    curRow = uniform(0, ROWS);
                    curCol = uniform(0, COLS);
                    flag++;
                }
                while ( (enemyBoard.hits[curRow][curCol] == 'X' || enemyBoard.hits[curRow][curCol] == 'Y') && flag < 200);
            }
            if (enemyBoard.hits[curRow][curCol] != 'X' && enemyBoard.hits[curRow][curCol] != 'Y') {
                enemyBoard.hits[curRow][curCol] = 'Y';
                shots++;
            }
            if (flag2 > 5000)
                break;
        }


        return enemyBoard;
    }

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

    void get_start(ref int row, ref int col, ref int dir, ref int sum) {
        if (uniform(0, 2))
            col = 0;
        else
            col = 9;
        if (uniform(0, 2))
            row = 0;
        else
            row = 9;
        if (uniform(0, 2)) {
            col = uniform(0, 10 - sum);
            dir = 1;
        }
        else {
            row = uniform(0, 10 - sum);
            dir = 0;
        }
    }

    override Board prepareMove()
    {
        initBoard (myBoard);
        initBoard (enemyBoard);

        for (int len = 1; len < 5; len++) {
              for (int num = 1; num <= 5 - len; num++)
              {

                  int rrow = uniform(0, 10);
                  int rcol = uniform(0, 10);
                  int rdir = uniform(0, 2);
                  if (len > 2)
                     get_start(rrow, rcol, rdir, len);
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
