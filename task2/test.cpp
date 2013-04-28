#include <iostream>
#include <random>
#include <functional>
#include <vector>
#include <iomanip>
#include <cmath>
#include <memory>

extern "C"
{
    
    void fdct (float * source, float * destination, int count);
    void idct (float * source, float * destination, int count);
    
}

float coef (int i)
{
    return (i == 0) ? sqrt(0.125) : 0.5;
}

float ccos (int a, int b)
{
    static const float pi8 = 3.141592653589793 / 8; 
    return cos(pi8 * (b + 0.5) * a) * coef(a);
}

enum direction_t {FORWARD, INVERSE};

void test_dct8_impl (float * src, float * dst, int count, direction_t dir)
{
    
    for (int m = 0; m < count; ++m)
    {        
        for (int i = 0; i < 8; ++i)
        for (int j = 0; j < 8; ++j)
        {
            float * c = dst + (m * 8 * 8 + i * 8 + j);
            *c = 0;
            for (int x = 0; x < 8; ++x)
            {
                for (int y = 0; y < 8; ++y)
                    *c += src[m * 8 * 8 + x * 8 + y]
                        * ((dir == FORWARD)
                        ?   ccos(i, x) * ccos(j, y)
                        :   ccos(x, i) * ccos(y, j)
                        );
            }
            if (dir == FORWARD)
                *c /= 8.0;
            else
                *c *= 8.0;
        }
    }
}

void test_dct8 (float * src, float * dst, int count)
{
    test_dct8_impl(src, dst, count, FORWARD);
}

void test_idct8 (float * src, float * dst, int count)
{
    test_dct8_impl(src, dst, count, INVERSE);
}

/*

Sample data;

    {
        -76, -73, -67, -62, -58, -67, -64, -55,
        -65, -69, -73, -38, -19, -43, -59, -56,
        -66, -69, -60, -15,  16, -24, -62, -55,
        -65, -70, -57,  -6,  26, -22, -58, -59,
        -61, -67, -60, -24,  -2, -40, -60, -58,
        -49, -63, -68, -58, -51, -60, -70, -53,
        -43, -57, -64, -69, -73, -67, -63, -45,
        -41, -49, -59, -60, -63, -52, -50, -34
    };

*/

int main ( )
{
    
    auto random = std::bind(std::uniform_real_distribution<float>(-9.9, 9.9), std::default_random_engine());
    
    std::cout << std::setfill(' ') << std::setprecision(2) << std::fixed;
    
    int matrices = 4;
    
    size_t size = matrices * 8 * 8;
    
    float * src_ = new float[size + 16];
    float * dst_ = new float[size + 16];
    
    auto align = [] (float * ptr) -> float *
    {
        if (((unsigned int)ptr & 0x10) != (unsigned int)ptr)
            ptr = (float *)(((unsigned int)ptr | 0xf) + 1);
        return ptr;
    };
    
    float * src = align(src_);
    float * dst = align(dst_);
    
    for (int i = 0; i < matrices * 8 * 8; ++i)
        src[i] = random();
        
    auto print = [matrices] (float * v) -> void
    {
        for (int m = 0; m < matrices; ++m)
        {
            for (int i = 0; i < 8; ++i)
            {
                for (int j = 0; j < 8; ++j)
                    std::cout << std::setw(5) << v[m * 8 * 8 + i * 8 + j] << ' ';
                std::cout << std::endl;
            }
            std::cout << std::endl;
        }
    };
    
    std::cout << "Before: " << std::endl << std::endl;
    print(src);
    
    fdct(src, dst, matrices);
    
    std::cout << "Middle: " << std::endl << std::endl;
    print(dst);
    
    idct(dst, src, matrices);
    
    std::cout << "After: " << std::endl << std::endl;
    print(src);
    
    delete [] src_;
    delete [] dst_;
}
