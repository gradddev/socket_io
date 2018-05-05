package com.semigradsky.socketio

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.socket.client.IO
import io.socket.client.Socket
import io.socket.emitter.Emitter
import org.json.JSONArray
import org.json.JSONObject
import java.util.*
import java.util.logging.Logger


class SocketIoPlugin private constructor(private val registrar: Registrar) : MethodCallHandler {
  companion object {
    @JvmStatic
    private val logger = Logger.getLogger("Socket.IO Plugin")

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), getChannelName())
      channel.setMethodCallHandler(SocketIoPlugin(registrar))
    }

    @JvmStatic
    private fun getChannelName(instanceId: String? = null): String {
      instanceId?.let {
        return "semigradsky.com/socket.io/$instanceId"
      }
      return "semigradsky.com/socket.io"
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "newInstance" -> {
        val uri = call.argument<String>("uri")
        val instanceId = newInstance(uri)
        result.success(instanceId)
      }
      "connect" -> {
        val instanceId = call.argument<String>("instanceId")
        connect(instanceId)
        result.success(null)
      }
      "on" -> {
        val instanceId = call.argument<String>("instanceId")
        val eventName = call.argument<String>("eventName")
        on(instanceId, eventName)
        result.success(null)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun generateInstanceId(): String {
    return UUID.randomUUID().toString()
  }

  private val sockets = mutableMapOf<String, Socket>()
  private val eventChannels = mutableMapOf<String, EventChannel>()
  private val eventSinks = mutableMapOf<String, EventChannel.EventSink>()

  private fun newInstance(uri: String): String {
    val instanceId = generateInstanceId()
    // TODO: add hostname verifier
    // TODO: add ssl certificate verifier
    val socket = IO.socket(uri)
    val eventChannel = EventChannel(
      registrar.messenger(),
      getChannelName(instanceId)
    )

    eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
        eventSink?.let {
          eventSinks[instanceId] = eventSink
        }
      }

      override fun onCancel(arguments: Any?) {
        eventSinks.remove(instanceId)
        socket.close()
      }
    })

    sockets[instanceId] = socket
    eventChannels[instanceId] = eventChannel

    return instanceId
  }

  private fun connect(instanceId: String) {
    val socket = sockets[instanceId]
    socket?.connect()
  }

  private fun on(instanceId: String, eventName: String) {
    val socket = sockets[instanceId]
    val eventSink = eventSinks[instanceId]
    val listener = Emitter.Listener({ it ->
      val arguments = it.toList().map { argument ->
        when (argument) {
          is JSONArray -> return@map argument.toString()
          is JSONObject -> return@map argument.toString()
          is Throwable -> {

            return@Listener
          }
          else -> return@map argument
        }
      }
      try {
        eventSink?.success(mapOf(
          "eventName" to eventName,
          "arguments" to arguments
        ))
      } catch (t: Throwable) {
        eventSink?.error(t.javaClass.name, t.message, t.stackTrace.toString())
      }
    })
    socket?.on(eventName, listener)
  }
}
