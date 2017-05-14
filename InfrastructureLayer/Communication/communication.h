#ifndef COMMUNICATION_H
#define COMMUNICATION_H

#include "communication_global.h"

#include <QTcpSocket>
#include <QByteArray>

class COMMUNICATIONSHARED_EXPORT Communication
{

public:
    Communication();

    bool connectToServer(const QString& host, quint16 port);

    qint64 write(const QByteArray &byteArray);
    QByteArray readData();

    bool connected(){ return m_socket.isOpen();}

private:
    QTcpSocket m_socket;
};

#endif // COMMUNICATION_H