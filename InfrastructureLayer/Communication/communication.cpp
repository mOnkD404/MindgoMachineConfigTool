﻿#include "communication.h"
#include <QHostAddress>
#include <QNetworkProxy>

Communication::Communication()
{
}

bool Communication::connectToServer(const QString& host, quint16 port)
{
    if(m_socket.isOpen())
    {
        m_socket.close();
        m_socket.waitForDisconnected();
    }
    m_socket.setProxy(QNetworkProxy::NoProxy);
    m_socket.connectToHost(QHostAddress(host),port);
    return m_socket.waitForConnected(3000);
}

qint64 Communication::write(const QByteArray &byteArray)
{
    if(m_socket.isWritable())
    {
        return m_socket.write(byteArray);
    }
    else
    {
        qWarning("socket write error!");
        return 0;
    }
}

QByteArray Communication::readData(int msecs)
{
    if (m_socket.waitForReadyRead(msecs))
    {
        return m_socket.read(m_socket.bytesAvailable());
    }
    else
    {
        qWarning("socket read error!");
        return 0;
    }
}

void Communication::disconnect()
{
    if(m_socket.isOpen())
    {
        m_socket.close();
    }
}
