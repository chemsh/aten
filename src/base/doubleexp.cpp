/*
	*** Double/Exponent value
	*** src/base/doubleexp.cpp
	Copyright T. Youngs 2007-2010

	This file is part of Aten.

	Aten is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	Aten is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Aten.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "base/doubleexp.h"
#include <math.h>
#include <stdio.h>

// Constructor
DoubleExp::DoubleExp(double mantissa, int exponent)
{
	// Private variables
	mantissa_ = mantissa;
	exponent_ = exponent;
	recalculate();
}

// Recalculate value
void DoubleExp::recalculate()
{
	value_ = mantissa_ * pow(10,exponent_);
}

// Retrieve full, real value
double DoubleExp::value()
{
	return value_;
}

// Set mantissa and exponent
void DoubleExp::set(double mantissa, int exponent)
{
	mantissa_ = mantissa;
	exponent_ = exponent;
	recalculate();
}

// Set from normal value
void DoubleExp::set(double value)
{
	exponent_ = 0;
	printf("A value of %f gives ",value);
	if (value > 1.0)
	{
		do
		{
			value /= 10.0;
			exponent_++;
		} while (value >= 10);
	}
	else if (value < 0.1)
	{
		do
		{
			value *= 10.0;
			exponent_--;
		} while (value < 1.0);
	}
	mantissa_ = value;
// 	printf("mantissa of %f and exponent of %i\n", value, mantissa_, exponent_);
}

// Set mantissa
void DoubleExp::setMantissa(double mantissa)
{
	mantissa_ = mantissa;
	recalculate();
}

// Return mantissa
double DoubleExp::mantissa()
{
	return mantissa_;
}

// Set exponent alone
void DoubleExp::setExponent(int exponent)
{
	exponent_ = exponent;
	recalculate();
}

// Return exponent
int DoubleExp::exponent()
{
	return exponent_;
}

// Assignment from single value
void DoubleExp::operator=(double d)
{
	set(d);
}