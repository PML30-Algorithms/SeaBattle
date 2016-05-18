module source.kazmenko;

import std.algorithm;
import std.random;
import std.range;

import source.seabattle;

class AI0 : Player
{
    override Board battleMove ()
    {
        return enemyBoard;
    }

    override Board prepareMove ()
    {
        initBoard (myBoard);
        initBoard (enemyBoard);

        bool isValid (int row, int col)
        {
        	return 0 <= row && row < ROWS &&
        	    0 <= col && col < COLS;
        }

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

        foreach_reverse (len; 0..MAX_LEN)
        {
        	foreach (k; 0..NUM_SHIPS[len])
        	{
        		while (!putShip (len))
        		{
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
