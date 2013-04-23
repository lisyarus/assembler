#include <iostream>
#include <cmath>

extern "C"
{
 
    float my_arctg (float x);
 
}

int main ( )
{
    while(true) {
        float x;
        std::cin >> x;
        std::cout << my_arctg(x) << ' ' << tan(my_arctg(x)) << std::endl;
    }
}
