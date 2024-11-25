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

class Fraction
{
    static ReduceImpl := Fraction.prototype.Reduce
    static CheckFractionImpl := Fraction.prototype.CheckFraction

    __New(Numerator := 0,Denominator := "")
    {
        this.Set(Numerator,Denominator)
    }

    Set(Numerator := 0,Denominator := "")
    {
        If (Denominator = "")
        {
            If Numerator Is Number
                this.FromNumber(Numerator)
            Else
                this.FromString(Numerator)
        }
        Else
        {
            If !IsInteger(Numerator)
                throw ValueError("Invalid numerator: " . Numerator)
            If !IsInteger(Denominator)
                throw ValueError("Invalid denominator: " . Denominator)
            If Denominator = 0
                throw ZeroDivisionError("Invalid denominator: " . Denominator)
            this.Numerator := Numerator
            this.Denominator := Denominator
        }
        Return this.Reduce()
    }

    FromNumber(Value,Error := 0.0001)
    {
        Loop
        {
            this.Denominator := A_Index
            this.Numerator := Round(Value * A_Index)
            If Abs((this.Numerator / this.Denominator) - Value) <= Error
                Break
        }
        Return this
    }

    FromString(Value)
    {
        If !RegExMatch(Value,"S)^\s*(-?\d+)\s*/\s*(-?\d+)\s*$",&Field)
            throw ValueError("Invalid fraction string: " . Value)
        If Field.2 = 0
            throw ZeroDivisionError("Invalid denominator: " . Field.2)
        this.Numerator := Field.1
        this.Denominator := Field.2
        Return this.Reduce()
    }

    Fast(Flag := True)
    {
        
        If Flag ;enable fast mode
        {
            this.DefineProp("Reduce", {Call: (p) => p})
            this.DefineProp("CheckFraction", {Call: (p) => {}})
        }
        Else ;disable fast mode
        {
            this.DefineProp("Reduce", {Call: Fraction.ReduceImpl})
            this.DefineProp("CheckFraction", {Call: Fraction.CheckFractionImpl})
            this.Reduce()
        }
        Return this
    }

    CheckFraction(Value) {
      if (!Value.HasOwnProp("Numerator") || !Value.HasOwnProp("Denominator")) {
        throw ValueError("Invalid fraction: " . Value, -2)
      }
    }

    IntegerGCD(Number1,Number2) ;greatest common divisor
    {
        While Number2 != 0
        {
            Remainder := Mod(Number1,Number2)
            Temp1 := Abs(Remainder - Number2)
            Number1 := Number2, Number2 := (Remainder > Temp1) ? Temp1 : Remainder
        }
        Return Abs(Number1)
    }

    Reduce() ;reduce fraction to simplest form
    {
        GCD := this.IntegerGCD(this.Numerator,this.Denominator)
        this.Numerator //= GCD
        this.Denominator //= GCD
        If this.Denominator < 0
        {
            this.Numerator := -this.Numerator
            this.Denominator := -this.Denominator
        }
        Return this
    }

    ToNumber()
    {
        Return this.Numerator / this.Denominator
    }

    ToString()
    {
        Return this.Numerator . "/" . this.Denominator
    }

    Equal(Value)
    {
        this.CheckFraction(Value)
        Return (this.Numerator * Value.Denominator) = (Value.Numerator * this.Denominator)
    }

    Less(Value)
    {
        this.CheckFraction(Value)
        If (this.Denominator < 0) ^ (Value.Denominator < 0) ;difference has negative denominator
            Return (this.Numerator * Value.Denominator) > (Value.Numerator * this.Denominator)
        Else
            Return (this.Numerator * Value.Denominator) < (Value.Numerator * this.Denominator)
    }

    LessOrEqual(Value)
    {
        this.CheckFraction(Value)
        If (this.Denominator < 0) ^ (Value.Denominator < 0) ;difference has negative denominator
            Return (this.Numerator * Value.Denominator) >= (Value.Numerator * this.Denominator)
        Else
            Return (this.Numerator * Value.Denominator) <= (Value.Numerator * this.Denominator)
    }

    Greater(Value)
    {
        this.CheckFraction(Value)
        If (this.Denominator < 0) ^ (Value.Denominator < 0) ;difference has negative denominator
            Return (this.Numerator * Value.Denominator) < (Value.Numerator * this.Denominator)
        Else
            Return (this.Numerator * Value.Denominator) > (Value.Numerator * this.Denominator)
    }

    GreaterOrEqual(Value)
    {
        this.CheckFraction(Value)
        If (this.Denominator < 0) ^ (Value.Denominator < 0) ;difference has negative denominator
            Return (this.Numerator * Value.Denominator) <= (Value.Numerator * this.Denominator)
        Else
            Return (this.Numerator * Value.Denominator) >= (Value.Numerator * this.Denominator)
    }

    Sign()
    {
        If this.Numerator = 0
            Return 0
        If ((this.Numerator < 0) ^ (this.Denominator < 0))
            Return -1
        Return 1
    }

    Abs()
    {
        this.Numerator := Abs(this.Numerator)
        this.Denominator := Abs(this.Denominator)
        Return this
    }

    Add(Value)
    {
        this.CheckFraction(Value)
        this.Numerator := (this.Numerator * Value.Denominator) + (Value.Numerator * this.Denominator)
        this.Denominator *= Value.Denominator
        Return this.Reduce()
    }

    Subtract(Value)
    {
        this.CheckFraction(Value)
        this.Numerator := (this.Numerator * Value.Denominator) - (Value.Numerator * this.Denominator)
        this.Denominator *= Value.Denominator
        Return this.Reduce()
    }

    Multiply(Value)
    {
        this.CheckFraction(Value)
        this.Numerator *= Value.Numerator
        this.Denominator *= Value.Denominator
        Return this.Reduce()
    }

    Divide(Value)
    {
        this.CheckFraction(Value)
        If Value.Numerator = 0 ;division by zero
            throw ZeroDivisionError("Invalid divisor: " . Value.ToString())
        this.Numerator *= Value.Denominator
        this.Denominator *= Value.Numerator
        Return this.Reduce()
    }

    Remainder(Value)
    {
        this.CheckFraction(Value)
        IntegerQuotient := (this.Numerator * Value.Denominator) // (this.Denominator * Value.Numerator) ;floor divide the two values
        Numerator := Value.Numerator * IntegerQuotient
        this.Numerator := (this.Numerator * Value.Denominator) - (Numerator * this.Denominator)
        this.Denominator *= Value.Denominator
        Return this.Reduce()
    }

    Exponentiate(Value)
    {
        If !IsInteger(Value) ;ensure the exponent is a whol number
            throw ValueError("Invalid exponent: " . Value)
        If Value >= 0 ;positive exponent
        {
            this.Numerator := this.Numerator ** Value
            this.Denominator := this.Denominator ** Value
        }
        Else ;negative exponent
        {
            Numerator := this.Denominator ** Value
            this.Denominator := this.Numerator ** Value
            this.Numerator := Numerator
        }
        Return this.Reduce()
    }

    GCD(Value) ;greatest common divisor (GCD(a/b,c/d)=GCD(a*d,b*c)/b*d)
    {
        this.CheckFraction(Value)
        this.Numerator := this.IntegerGCD(this.Numerator * Value.Denominator,Value.Numerator * this.Denominator)
        this.Denominator := Abs(this.Denominator * Value.Denominator)
        Return this.Reduce()
    }

    LCM(Value) ;least common multiple (LCM(a/b,c/d)=LCM(a*d,b*c)/b*d)
    {
        this.CheckFraction(Value)
        Number1 := this.Numerator * Value.Denominator
        Number2 := Value.Numerator * this.Denominator
        this.Numerator := Abs(Number1 * Number2) // this.IntegerGCD(Number1,Number2)
        this.Denominator := Abs(this.Denominator * Value.Denominator)
        Return this.Reduce()
    }
}

