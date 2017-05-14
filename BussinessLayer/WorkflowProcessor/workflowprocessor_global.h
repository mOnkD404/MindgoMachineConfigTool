#ifndef WORKFLOWPROCESSOR_GLOBAL_H
#define WORKFLOWPROCESSOR_GLOBAL_H

#include <QtCore/qglobal.h>

#if defined(WORKFLOWPROCESSOR_LIBRARY)
#  define WORKFLOWPROCESSORSHARED_EXPORT Q_DECL_EXPORT
#else
#  define WORKFLOWPROCESSORSHARED_EXPORT Q_DECL_IMPORT
#endif

#endif // WORKFLOWPROCESSOR_GLOBAL_H