/*
Copyright 2013 Anthony Zhang <azhang9@gmail.com>

This file is part of Fraction.ahk. Source code is available at <https://github.com/Uberi/Fraction.ahk>.

Fraction.ahk is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

If TestFraction().Run(&Pass,&Fail)
    MsgBox "All tests passed."
Else
{
    Result := ""
    For Index, Name In Fail
        Result .= "`n" . Name
    MsgBox "Some tests failed:`n" . Result
}

#Include %A_ScriptDir%\Fraction.ahk

class TestFraction
{
    testCreate()
    {
        f := Fraction(-3,-2)
        Return this.Check(f,3,2)
    }

    testFast()
    {
        f := Fraction()
        f.Fast().Set(5,10)
        Return this.Check(f,5,10)
    }

    testReduce()
    {
        f := Fraction(45,-9)
        t := f.Reduce()
        Return this.Check(t,-5,1)
    }

    testSet()
    {
        f := Fraction()
        Return this.Check(f.Set(4,-7),-4,7)
    }

    testFromNumber()
    {
        f := Fraction()
        Return this.Check(f.Set(-0.457),-69,151)
    }

    testFromString()
    {
        f := Fraction()
        Return this.Check(f.Set("  -45  /  -7   "),45,7)
    }

    testToNumber()
    {
        f := Fraction(5,4)
        Return f.ToNumber() = 1.25
    }

    testToString()
    {
        f := Fraction(3,-2)
        Return f.ToString() = "-3/2"
    }

    testEqual()
    {
        f := Fraction(5,-6)
        Return f.Equal(Fraction(-20,24))
    }

    testLess()
    {
        f := Fraction(-1,7)
        Return f.Less(Fraction(4,3))
    }

    testLessOrEqual()
    {
        f := Fraction(5,-7)
        Return f.Less(Fraction(-2,3))
    }

    testGreater()
    {
        f := Fraction(1,-6)
        Return f.Greater(Fraction(-2,3))
    }

    testGreaterOrEqual()
    {
        f := Fraction(7,9)
        Return f.GreaterOrEqual(Fraction(4,10))
    }

    testSign()
    {
        f := Fraction(-1,-2)
        Return f.Sign() = 1
    }

    testAbs()
    {
        f := Fraction(9,-6)
        Return this.Check(f.Abs(),3,2)
    }

    testAdd()
    {
        f := Fraction(7,6)
        Return this.Check(f.Add(Fraction(4,9)),29,18)
    }

    testSubtract()
    {
        f := Fraction(7,4)
        Return this.Check(f.Subtract(Fraction(2,5)),27,20)
    }

    testMultiply()
    {
        f := Fraction(5,2)
        Return this.Check(f.Divide(Fraction(4,3)),15,8)
    }

    testDivide()
    {
        f := Fraction(2,6)
        Return this.Check(f.Divide(Fraction(7,5)),5,21)
    }

    testRemainder()
    {
        f := Fraction(5,-3)
        t := f.Remainder(Fraction(-3,2))
        Return this.Check(t,-1,6)
    }

    testExponentiate()
    {
        f := Fraction(-4,-2)
        t := f.Exponentiate(3)
        Return this.Check(t,8,1)
    }

    testGCD()
    {
        f := Fraction(-3,4)
        t := f.GCD(Fraction(21,23))
        Return this.Check(t,3,92)
    }

    testLCM()
    {
        f := Fraction(4,-3)
        t := f.LCM(Fraction(-2,7))
        Return this.Check(t,4,1)
    }

    Check(Value,Numerator,Denominator)
    {
        Return Value.Numerator = Numerator && Value.Denominator = Denominator
    }

    Run(&Pass,&Fail)
    {
        Pass := []
        Fail := []
        For Name In TestFraction.Prototype.OwnProps()
        {
            If SubStr(Name,1,4) = "test"
            {
                Result := ObjBindMethod(this, Name)()
                If Result
                    Pass.Push(Name)
                Else
                    Fail.Push(Name)
            }
        }
        Return !Fail.Length
    }
}
