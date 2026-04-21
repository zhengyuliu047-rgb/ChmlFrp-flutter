cmake_minimum_required(VERSION 3.14)
project(frpc_integration LANGUAGES CXX)

# 设置C++标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 禁用警告作为错误
if(MSVC)
    string(REGEX REPLACE "/WX" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
endif()

# 添加源文件
add_library(frpc_integration STATIC
    config_generator.cpp
    process_manager.cpp
)

# 包含目录
target_include_directories(frpc_integration PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# 链接Windows库
target_link_libraries(frpc_integration PRIVATE
    kernel32.lib
    user32.lib
    gdi32.lib
    winspool.lib
    comdlg32.lib
    advapi32.lib
    shell32.lib
    ole32.lib
    oleaut32.lib
    uuid.lib
    odbc32.lib
    odbccp32.lib
)

# 设置编译选项
if(MSVC)
    target_compile_options(frpc_integration PRIVATE
        /W4
        /EHsc
    )
endif()