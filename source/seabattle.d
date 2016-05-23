module source.razuvaev;

import std.stdio;
import std.algorithm;
import std.math;
import std.random;
import std.conv;
import std.random;


import source.seabattle;

class RazuvaevAI : Player
{
    //////START//////
    int curRow = 0;//
    int curCol = 0;//
    int step = 0;  //
    int flag = 1;  //
    /////////////////

    bool isHit (int row, int col)
    {
        if ((row>=0)&&(col>=0)&&(row<=9)&&(col<=9))
        {
            //writeln("API: isHit: DONT SEACH:");
            //write  ("            row = ");writeln(row);
            //write  ("            col = ");writeln(col);
            return (enemyBoard.hits[row][col] == 'X' && enemyBoard.ships[row][col] == 'O');
        }
        else
            return false;
    }
    bool isNull (int row, int col)
    {
        if ((row>=0)&&(col>=0)&&(row<=9)&&(col<=9))
        {
            return (enemyBoard.hits[row][col] == '.');
        }
        else
            return 0;
    }

    override Board battleMove()
    {
        int shots = 0;
        write("API: FLAG = ");writeln(flag);
        while ((shots < myBoard.MaxShots())&&(flag == 1))
        {
        enemyBoard.hits[curRow][curCol] = 'Y';
        shots++;
            if (curRow%2==0){
                curCol += 2;
                if (curCol >= COLS){
                    curCol = 1;
                    curRow++;
                }
            }
            else
            if (curRow%2==1)
            {
                curCol += 2;
                if (curCol >= COLS)
                {
                    if (curRow+1 < ROWS){
                        curCol = 0;
                        curRow++;
                    }
                    else
                    {
                        flag = 2;
                        curRow = 0;
                        curCol = 0;
                    }
                }
            }
        }

        //  POISK 4Palubnika
        int dead4 = -1;
        int flalalag = 1;
        if (flag == 2)
        {
        dead4 = 0;
        }
        write("API: FLAG = ");writeln(flag);
        while ((shots < myBoard.MaxShots())&&(flag == 2)&&(flalalag))/////////////////////////////////////////////////////////////
        {   writeln("API: POISK 4Palubnika: Started");
            write("API: POISK 4Palubnika: shots = ");writeln(shots);
            write("API: POISK 4Palubnika: curRow = ");writeln(curRow);
            write("API: POISK 4Palubnika: curCol = ");writeln(curCol);
            //curCol - stolbci

            writeln("API: POISK 4Palubnika: ROW SEACH");
            write("API: FLAG = ");writeln(flag);
            if ((shots < myBoard.MaxShots())&&isHit(curRow-1, curCol) && isNull(curRow, curCol) && isHit(curRow+1, curCol))//poisk v stroke
            {
                writeln("API: POISK 4Palubnika: ROW SEACH: SEACHED!");
                enemyBoard.hits[curRow][curCol] = 'Y';
                shots ++;
            }
            else
            {
                writeln("API: POISK 4Palubnika: ROW SEACH: NO SEACHED!");
            }
            if ((shots < myBoard.MaxShots())&&isNull(curRow-1, curCol) && isHit(curRow, curCol) && isHit(curRow+1, curCol))//poisk v stroke
            {
                writeln("API: POISK 4Palubnika: ROW SEACH: SEACHED!");
                enemyBoard.hits[curRow][curCol] = 'Y';
                shots ++;
            }
            else
            {
                writeln("API: POISK 4Palubnika: ROW SEACH: NO SEACHED!");
            }
            if ((shots < myBoard.MaxShots())&&isHit(curRow-1, curCol) && isHit(curRow, curCol) && isNull(curRow+1, curCol))//poisk v stroke
            {
                writeln("API: POISK 4Palubnika: ROW SEACH: SEACHED!");
                enemyBoard.hits[curRow][curCol] = 'Y';
                shots ++;
            }
            else
            {
                writeln("API: POISK 4Palubnika: ROW SEACH: NO SEACHED!");
            }
            writeln("API: POISK 4Palubnika: COL SEACH");
            if ((shots < myBoard.MaxShots())&& isHit(curRow, curCol-1) &&
                isNull(curRow, curCol) && isHit(curRow, curCol+1))//poisk v stolbce
            {
                writeln("API: POISK 4Palubnika: SEACHED!");
                enemyBoard.hits[curRow][curCol] = 'Y';
                shots ++;
            }
            else
            {
                writeln("API: POISK 4Palubnika: COL SEACH: NO SEACHED!");
            }
            if ((shots < myBoard.MaxShots())&& isNull(curRow, curCol-1) &&
                isHit(curRow, curCol) && isHit(curRow, curCol+1))//poisk v stolbce
            {
                writeln("API: POISK 4Palubnika: SEACHED!");
                enemyBoard.hits[curRow][curCol] = 'Y';
                shots ++;
            }
            else
            {
                writeln("API: POISK 4Palubnika: COL SEACH: NO SEACHED!");
            }
            if ((shots < myBoard.MaxShots())&& isHit(curRow, curCol-1) &&
                isHit(curRow, curCol) && isNull(curRow, curCol+1))//poisk v stolbce
            {
                writeln("API: POISK 4Palubnika: SEACHED!");
                enemyBoard.hits[curRow][curCol] = 'Y';
                shots ++;
            }
            else
            {
                writeln("API: POISK 4Palubnika: COL SEACH: NO SEACHED!");
            }
              // Go...
            if(curCol>10){//esli stolbec
                curCol = 0;//stolbec = 0
                curRow ++;//perevod stroki
            }
            else
            {
                curCol ++;
            }
            for(int i = 0;i<10; i++){
                for(int j = 0;j<10; j++){
                    if ((isHit(i-1,j)&&isNull(i,j)&&isHit(i+1,j)&&isHit(i+2,j))||
                        (isHit(i,j-1)&&isNull(i,j)&&isHit(i,j+1)&&isHit(i,j+2)))
                    {
                        enemyBoard.hits[i][j] = 'Y';
                        shots ++;
                        writeln("API: POISK 4Palubnika: dead4?");
                    }
                }
            }
            if(curRow>=10)//esli stroka
            {
                curRow = 0;
                curCol = 0;
                //flalalag = 0;
                if (API_GO_2to3()){
                    flag = 3;
                    flalalag = 0;
                }
            }




            if(shots >= myBoard.MaxShots())
                flalalag = 0;

        }
        write("API: FLAG = ");writeln(flag);
        while ((shots < myBoard.MaxShots())&&(flag == 3)){//////////////////////////////////////////////////////////////////////
            writeln("API: Killing 4Palubnika: Started!");
            for(int i = 0;i<10; i++)
            {
                for(int j = 0;j<10; j++)
                    {
                    if ((isHit(i-1,j)&&isHit(i,j)&&isHit(i+1,j)&&isHit(i+2,j))||
                        (isHit(i,j-1)&&isHit(i,j)&&isHit(i,j+1)&&isHit(i,j+2)))
                            {
                                dead4 = 1;
                                writeln("API: Killing 4Palubnika: dead4!!!");
                                write("API: FLAG = ");writeln(flag);
                            }
                    }
            }
            if(dead4 == 1)
            {
                write("API: FLAG = ");writeln(flag);
                flag = 4;
                writeln("API: THE END");
                write("API: FLAG = ");writeln(flag);
            }
        }
        while ((shots < myBoard.MaxShots())&&(flag == 4)){
        }
    return enemyBoard;
    }
    bool API_GO_2to3(){
        writeln("API: API_GO_2to3...");
            for(int i = 0;i<10; i++)
            {
                for(int j = 0;j<10; j++)
                    {
                    if ((isHit(i-1,j)&&isNull(i,j)&&isHit(i+1,j))||
                        (isHit(i,j-1)&&isNull(i,j)&&isHit(i,j+1))||
                        (isNull(i-1,j)&&isHit(i,j)&&isHit(i+1,j))||
                        (isNull(i,j-1)&&isHit(i,j)&&isHit(i,j+1))||
                        (isHit(i-1,j)&&isHit(i,j)&&isNull(i+1,j))||
                        (isHit(i,j-1)&&isHit(i,j)&&isNull(i,j+1)))
                            {
                                return false;
                            }
                    }
            }
        return true;
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
