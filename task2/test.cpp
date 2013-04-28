#include <iostream>
#include <random>
#include <functional>
#include <vector>
#include <iomanip>

extern "C"
{
    
    void dct8 (float * source, float * destination, int count);
    void undct8 (float * source, float * destination, int count);
    
}

int main ( )
{
    auto random = std::bind(std::uniform_real_distribution<float>(0.0, 0.1), std::default_random_engine());
    
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
    dct8(src.data(), dst.data());
    std::cout << "After DCT: " << std::endl;
    print(dst);
    
}
