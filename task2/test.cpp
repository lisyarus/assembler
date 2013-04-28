#include <iostream>
#include <random>
#include <functional>
#include <vector>
#include <iomanip>
#include <cmath>

extern "C"
{
    
    void dct8 (float * source, float * destination, int count);
    void undct8 (float * source, float * destination, int count);
    
}

float coef (int i)
{
    return (i == 0) ? sqrt(0.125) : 0.5;
}

void test_dct8 (float * src, float * dst, int count)
{
    const float pi8 = 3.141592653589793 / 8; 
    
    for (int m = 0; m < count; ++m)
    {
        for (int i = 0; i < 8; ++i)
        for (int j = 0; j < 8; ++j)
        {
            float * c = dst + (m * 8 * 8 + i * 8 + j);
            *c = 0.0;
            for (int x = 0; x < 8; ++x)
            for (int y = 0; y < 8; ++y)
                *c += src[m * 8 * 8 + x * 8 + y]
                    * cos(pi8 * (x + 0.5) * i)
                    * cos(pi8 * (y + 0.5) * j);
            *c *= coef(i);
            *c *= coef(j);
        }
    }
}

void test_undct8 (float * src, float * dst, int count)
{
    const float pi8 = 3.141592653589793 / 8; 
    
    for (int m = 0; m < count; ++m)
    {
        for (int x = 0; x < 8; ++x)
        for (int y = 0; y < 8; ++y)
        {
            float * c = dst + (m * 8 * 8 + x * 8 + y);
            *c = 0.0;
            for (int i = 0; i < 8; ++i)
            for (int j = 0; j < 8; ++j)
                *c += src[m * 8 * 8 + i * 8 + j]
                    * cos(pi8 * (x + 0.5) * i)
                    * cos(pi8 * (y + 0.5) * j)
                    * coef(i) * coef(j);
        }
    }
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
    auto random = std::bind(std::uniform_real_distribution<float>(0.0, 1.0), std::default_random_engine());
    
    std::cout << std::setfill('0') << std::setprecision(3) << std::fixed;
    
    int matrices = 1;
    std::vector<float> src(matrices * 8 * 8); 
    std::vector<float> dst(matrices * 8 * 8);
    
    for (int i = 0; i < src.size(); ++i)
        src[i] = random();
        
    auto print = [] (std::vector<float> v) -> void
    {
        for (int m = 0; m < v.size() / 64; ++m)
        {
            for (int i = 0; i < 8; ++i)
            {
                for (int j = 0; j < 8; ++j)
                    std::cout << v[m * 8 * 8 + i * 8 + j] << ' ';
                std::cout << std::endl;
            }
            std::cout << std::endl;
        }
    };
    
    print(src);
    
    test_dct8(src.data(), dst.data(), matrices);
    std::cout << "After DCT8: " << std::endl << std::endl;
    print(dst);
    
    test_undct8(dst.data(), src.data(), matrices);
    std::cout << "After UnDCT8: " << std::endl << std::endl;
    print(src);
    
}
