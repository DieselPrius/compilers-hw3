#ifndef SYMBOLDATA_H
#define SYMBOLDATA_H

#include <string>

class SymbolData
{
public:
        std::string m_type;
        std::string m_startSign;
        std::string m_startIndex;
        std::string m_endSign;
        std::string m_endIndex;
        std::string m_baseType;
        std::string m_lexeme;
        
        SymbolData()
        {
            m_type = "";
            m_startSign = "";
            m_startIndex = "";
            m_endSign = "";
            m_endIndex = "";
            m_baseType = "";
            m_lexeme = "";
        }


        SymbolData(const std::string type)
        {
            m_type = type;
        }


        SymbolData(const std::string type,
            const std::string startSign,
            const std::string startIndex,
            const std::string endSign,
            const std::string endIndex,
            const std::string baseType)
        {
            m_type = type;
            m_startSign = startSign;
            m_startIndex = startIndex;
            m_endSign = endSign;
            m_endIndex = endIndex;
            m_baseType = baseType;
        }

};

#endif