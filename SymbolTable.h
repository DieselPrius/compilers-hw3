#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <iostream>
#include <vector>
#include <string>
#include <map>
#include <stdexcept>
#include "SymbolData.h"

class SymbolTable
{
    private:
        std::vector<std::map<std::string,SymbolData>> m_table;
        bool showOutput = false;

    public:
        void pushScope()
        {
            if(showOutput)
                std::cout << "\n___Entering new scope...\n" << std::endl;

            m_table.push_back(std::map<std::string,SymbolData>());
        
            return;
        }

        void popScope()
        {
            if(showOutput)
                std::cout << "\n___Exiting scope...\n" << std::endl;

            m_table.pop_back();

            return;
        }

        void addEntry(const std::string symbolName, const SymbolData typeInfo, const int lineNumber)
        {
            //if(!findSymbolInCurrentScope(symbolName)) //if a redeclaration is not occuring
            
            if(showOutput)
            {
                if(typeInfo.m_type == "ARRAY")
                    std::cout << "___Adding " << symbolName << " to symbol table with type " << typeInfo.m_type << " " << typeInfo.m_startSign << "" << typeInfo.m_startIndex << " .. " << typeInfo.m_endSign << "" << typeInfo.m_endIndex << " OF " << typeInfo.m_baseType << std::endl;
                else
                    std::cout << "___Adding " << symbolName << " to symbol table with type " << typeInfo.m_type << std::endl;
            
            }
            
            if(!findSymbolInCurrentScope(symbolName)) //if a redeclaration is not occuring
                m_table[m_table.size()-1][symbolName] = typeInfo;
            else
            {
                if(showOutput)
                    std::cout << "Line " << lineNumber << ": Multiply defined identifier" << std::endl;
                exit(1);
            }

            return;
        }

        //returns true if a symbol already exists in the current scope
        bool findSymbolInCurrentScope(const std::string symbolName)
        {
            std::map<std::string,SymbolData>::iterator it;            
            bool isInTable = false;

            it = m_table[m_table.size()-1].find(symbolName);

            if(it != m_table[m_table.size()-1].end())
                isInTable = true;

            return isInTable;
        }


        SymbolData& getSymbolData(const std::string symbolName)
        {
            int vectorIndex = findSymbolInAnyScope(symbolName);

            if(vectorIndex == -1) //if symbolName is not in the symbol table
            {
                throw std::invalid_argument("symbol " + symbolName + " not found in symbol table");
            }
            
            return  m_table[vectorIndex][symbolName];
        }

        //find symbol in any scope starting from the most recent scope
        //returns the index of m_table in which the symbol was found or -1 if the symbol was not found
        int findSymbolInAnyScope(const std::string symbolName)
        {
            std::map<std::string,SymbolData>::iterator it;            
            bool isInTable = false;
            int counter = m_table.size()-1;
            int foundIndex = -1;
            
            while(counter >= 0 && !isInTable)
            {
                it = m_table[counter].find(symbolName);

                if(it != m_table[counter].end())
                {
                    isInTable = true;
                    foundIndex = counter;
                }

                counter--;
            }

            return foundIndex;
        }

};

#endif