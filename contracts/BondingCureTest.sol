pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

contract BondingCurveTest {
    using SafeMath for uint256;
    uint256 public k = 1;

    //TODO q max?

    // price for Tokes via Exp4
    function priceForTokensExp2(uint256 _q, uint256 q)
        public
        view
        returns (uint256)
    {
        uint256 a = 2;
        uint256 result = getResultExp2(_q, q);
        result = result.div(a).mul(k).div(1000);
        console.log("price22222:", result);
        return result;
    }

    function priceForTokensExp3(uint256 _q, uint256 q)
        public
        view
        returns (uint256)
    {
        uint256 a = 3;
        uint256 result = getResultExp3(_q, q);
        console.log("price3:", result);
        result = result.div(a).mul(k).div(1000);
        return result;
    }

    function getDeltaQForExp2(uint256 _price, uint256 q)
        public
        view
        returns (uint256)
    {
        uint256 a = 2;
        uint256 price = _price;
        price = price.mul(a.mul(1000).div(k)).add((q**a).div(1e36));
        console.log("deltaQ2:", price);
        price = price.mul(1e36);
        uint256 num = MathTools.sqrt(price);
        return num.sub(q.div(1e18));
    }

    function getDeltaQForExp3(uint256 _price, uint256 q)
        public
        view
        returns (uint256)
    {
        uint256 a = 3;
        uint256 price = _price;
        price = price.mul(a.mul(1000).div(k)).add((q**a).div(1e72));
        console.log("price:", price);
        ///@notice:
        ///@params3 must be 8, if not , will overflow
        uint256 num = MathTools.nthRoot(price, 3, 8, price);
        console.log("num", num);
        return num.mul(1e10).sub(q.div(1e18));
    }

    // exq 4
    function priceForTokensExp4(uint256 _q, uint256 q)
        public
        view
        returns (uint256)
    {
        uint256 a = 4;
        uint256 result = getResultExp4(_q, q);
        result = result.div(a).mul(k).div(1000);
        return result;
    }

    function getResultExp2(uint256 _q, uint256 q)
        public
        view
        returns (uint256 total)
    {
        uint256 a = 2;
        uint256 num1 = (_q**a).mul(1e14);
        console.log("num11111:", num1);
        uint256 num2 = _q.mul(q).mul(a).div(1e2);
        console.log("num2222", num2);
        uint256 total = num1.add(num2);
        console.log("getResultExp2:", total);
        return total;
    }

    function getResultExp3(uint256 _q, uint256 q)
        public
        view
        returns (uint256 total)
    {
        //
        uint256 a = 3;
        uint256 num1 = (_q**a).mul(1e12);
        console.log("num1", num1);
        uint256 num2 = _q.mul(q).mul(a);
        uint256 num3 = _q.add(q.mul(100));
        total = num1.add(num2.mul(num3).mul(1e14));
        return total;
    }

    function getResultExp4(uint256 _q, uint256 q)
        public
        view
        returns (uint256 total)
    {
        // 141.52
        uint256 a = 4;
        uint256 num1 = (_q**a).mul(1e10);
        console.log("num1:", num1);
        uint256 num2 = _q.mul(q).mul(a);
        console.log("num2:", num2);
        uint256 num3_1 = (q**a);
        console.log("num3_1:", num3_1);
        uint256 num3_2 = _q**a;
        console.log("num3_2:", num3_2);
        uint256 num3_3 = q.mul(_q);
        uint256 num3 = num3_1.add(num3_2).add(num3_3);
        uint256 total = num1.add(num2.mul(num3).mul(1e16));
        console.log("total:", total);
        return total;
    }

    function getDeltaQForExp4(uint256 price, uint256 q)
        public
        view
        returns (uint256)
    {
        uint256 a = 4;
        uint256 price = price;
        console.log("price:", price);
        uint256 num1 = price.mul(a.mul(1000).div(k)).add((q**a).div(1e72));
        console.log("Num1:", num1);
        // two time sqrt
        num1 = num1.mul(1e56);
        uint256 deltaQ = MathTools.sqrt(num1);
        return MathTools.sqrt(deltaQ).mul(1e4).sub(q.div(1e18));
    }
}

library MathTools {
    /// @notice Calculates the square root of x, rounding down.
    /// @dev Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
    /// @param x The uint256 number for which to calculate the square root.
    /// @return result The result as an uint256.
    function sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }

        // Calculate the square root of the perfect square of a power of two that is the closest to x.
        uint256 xAux = uint256(x);
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        // The operations can never overflow because the result is max 2^127 when it enters this block.
        unchecked {
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1; // Seven iterations should be enough
            uint256 roundedDownResult = x / result;
            return result >= roundedDownResult ? roundedDownResult : result;
        }
    }

    // calculates a^(1/n) to dp decimal places
    // maxIts bounds the number of iterations performed
    function nthRoot(
        uint256 _a,
        uint256 _n,
        uint256 _dp,
        uint256 _maxIts
    ) internal view returns (uint256) {
        assert(_n > 1);

        // The scale factor is a crude way to turn everything into integer calcs.
        // Actually do (a * (10 ^ ((dp + 1) * n))) ^ (1/n)
        // We calculate to one extra dp and round at the end
        uint256 one = 10**(1 + _dp);
        uint256 a0 = one**_n * _a;

        // Initial guess: 1.0
        uint256 xNew = one;
        uint256 x;
        uint256 iter = 0;
        while (xNew != x && iter < _maxIts) {
            x = xNew;
            uint256 t0 = x**(_n - 1);
            if (x * t0 > a0) {
                xNew = x - (x - a0 / t0) / _n;
            } else {
                xNew = x + (a0 / t0 - x) / _n;
            }
            ++iter;
        }

        // Round to nearest in the last dp.
        return (xNew + 5) / 10;
    }
}
