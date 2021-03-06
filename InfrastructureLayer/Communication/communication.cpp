﻿#include "communication.h"
#include <QHostAddress>
#include <QNetworkProxy>
#include <QTimer>
#include <QEvent>
#include <QThread>

Communication::Communication(QObject* parent):QObject(parent),m_closeTimer(0)
{
}

bool Communication::connectToServer(const QString& host, quint16 port)
{
    if(m_socket.isOpen())
    {
        if(m_socket.peerAddress() == QHostAddress(host) && m_socket.peerPort() == port)
        {
            killTimer(m_closeTimer);
            if(m_socket.bytesAvailable() > 0)
            {
                m_socket.readAll();
            }
            return true;
        }
        else
        {
            m_socket.close();
            m_socket.waitForDisconnected();
        }
    }
    m_socket.setProxy(QNetworkProxy::NoProxy);
    m_socket.connectToHost(QHostAddress(host),port);
    return m_socket.waitForConnected(3000);
}

qint64 Communication::write(const QByteArray &byteArray)
{
    QThread::msleep(100);
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
        if (m_socket.state() == QAbstractSocket::UnconnectedState ||
                  m_socket.waitForDisconnected())
        {
            qDebug()<<"socket closed";
        }
    }
}

void Communication::disconnectLater(int time)
{
    if(m_socket.isOpen())
    {
        m_closeTimer = startTimer(time);
    }
}

void Communication::timerEvent(QTimerEvent* event)
{
    if(event->timerId() == m_closeTimer)
    {
        disconnect();
        killTimer(m_closeTimer);
    }
}
