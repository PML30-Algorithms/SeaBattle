module source.kazmenko;

import std.algorithm;
import std.random;
import std.range;
import std.stdio;
import std.typecons;

import source.seabattle;

class AI0 : Player
{
    alias Coord = Tuple !(int, q{row}, int, q{col});

    bool isValid (int row, int col)
    {
    	return 0 <= row && row < ROWS &&
    	    0 <= col && col < COLS;
    }

    bool isHit (int row, int col)
    {
        return enemyBoard.hits[row][col] == 'X' && enemyBoard.ships[row][col] == 'O';
    }

    override Board battleMove ()
    {
        debug {writeln ("AI0 battleMove begin");}
        immutable int DIRS = 4;
        immutable int [DIRS] DROW = [ 0, +1,  0, -1];
        immutable int [DIRS] DCOL = [+1,  0, -1,  0];

        int shots = min (myBoard.MaxShots (), ROWS * COLS -
            enemyBoard.hits[].map !(x => x[].map !(y => y == 'X').sum).sum);
        Coord [] c;
        foreach (row; 0..ROWS)
        {
            foreach (col; 0..COLS)
            {
                if (isHit (row, col))
                {
                    foreach (dir; 0..DIRS)
                    {
                        int nrow = row + DROW[dir];
                        int ncol = col + DCOL[dir];
                        if (isValid (nrow, ncol) && enemyBoard.hits[nrow][ncol] == '.')
                        {
                            c ~= Coord (nrow, ncol);
                        }
                    }
                }
            }
        }
        randomShuffle (c);
        foreach (cell; c)
        {
            int row = cell.row;
            int col = cell.col;
            if (enemyBoard.hits[row][col] == '.')
            {
                enemyBoard.hits[row][col] = 'Y';
                shots--;
                if (shots == 0)
                {
                    break;
                }
            }
        }
        while (shots)
        {
            int row = uniform (0, ROWS);
            int col = uniform (0, COLS);
            if (enemyBoard.hits[row][col] == '.')
            {
                enemyBoard.hits[row][col] = 'Y';
                shots--;
            }
        }
endBattleMove:
        debug {writeln ("AI0 battleMove end");}
        return enemyBoard;
    }

    override Board prepareMove ()
    {
        debug {writeln ("AI0 prepareMove begin");}
        initBoard (myBoard);
        initBoard (enemyBoard);

        bool isEmpty (int row, int col)
        {
        	return !isValid (row, col) ||
        	    myBoard.ships[row][col] == '.';
        }

        bool putShip (int len)
        {
            int row = uniform (0, ROWS);
            int col = uniform (0, COLS);
            int dir = uniform (0, 2);

            immutable int DIRS = 2;
            immutable int [DIRS] DROW = [ 0, +1];
            immutable int [DIRS] DCOL = [+1,  0];

            if (!isValid (row + DROW[dir] * (len - 1),
                col + DCOL[dir] * (len - 1)))
            {
                return false;
            }
            if (!isEmpty (row + DROW[dir] * (-1), col + DCOL[dir] * (-1)))
            {
                return false;
            }
            if (!isEmpty (row + DROW[dir] * len, col + DCOL[dir] * len))
            {
                return false;
            }
            foreach (i; 0..len)
            {
                foreach (norm; -1..+2)
                if (!isEmpty (row + DROW[dir] * i + DCOL[dir] * norm,
                    col + DCOL[dir] * i - DROW[dir] * norm))
                {
                    return false;
                }
            }
            foreach (i; 0..len)
            {
                myBoard.ships[row + DROW[dir] * i][col + DCOL[dir] * i] = 'O';
            }
            return true;
        }

        foreach_reverse (len; 0..MAX_LEN + 1)
        {
        	foreach (k; 0..NUM_SHIPS[len])
        	{
        		while (!putShip (len))
        		{
        		}
        	}
        }

        debug {writeln ("AI0 prepareMove end");}
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
