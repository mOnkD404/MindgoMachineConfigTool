#ifndef WORKFLOWPROTOCOL_GLOBAL_H
#define WORKFLOWPROTOCOL_GLOBAL_H

#include <QtCore/qglobal.h>

#if defined(WORKFLOWPROTOCOL_LIBRARY)
#  define WORKFLOWPROTOCOLSHARED_EXPORT Q_DECL_EXPORT
#else
#  define WORKFLOWPROTOCOLSHARED_EXPORT Q_DECL_IMPORT
#endif

#endif // WORKFLOWPROTOCOL_GLOBAL_H
