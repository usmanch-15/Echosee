import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '../controllers/live_transcription_controller.dart';
import '../services/bluetooth_glasses_service.dart';

class LiveTranscriptionScreen extends StatelessWidget {
  const LiveTranscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveTranscriptionController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'EcoC Live',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: controller.isInitializing
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ConnectionPanel(controller: controller),
                        const SizedBox(height: 12),
                        _ControlRow(controller: controller),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _TranscriptPanel(controller: controller),
                        ),
                        const SizedBox(height: 12),
                        _ListenButton(controller: controller),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _ConnectionPanel extends StatelessWidget {
  const _ConnectionPanel({required this.controller});

  final LiveTranscriptionController controller;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(controller.connectionState);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusStyle.color, width: 1.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusStyle.icon, color: statusStyle.color, size: 22),
              const SizedBox(width: 8),
              Text(
                statusStyle.label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: statusStyle.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            controller.connectionMessage,
            style: const TextStyle(fontSize: 16, height: 1.35),
          ),
          if (controller.scanResults.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Available Devices',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: ListView.separated(
                itemCount: controller.scanResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final result = controller.scanResults[index];
                  return _DeviceTile(
                    result: result,
                    onConnect: () => controller.connect(result),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ControlRow extends StatelessWidget {
  const _ControlRow({required this.controller});

  final LiveTranscriptionController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          onPressed: controller.refreshDevices,
          icon: const Icon(Icons.search),
          label: const Text('Scan'),
        ),
        FilledButton.icon(
          onPressed: controller.autoConnect,
          icon: const Icon(Icons.bluetooth_searching),
          label: const Text('Auto Connect'),
        ),
        OutlinedButton.icon(
          onPressed: controller.disconnect,
          icon: const Icon(Icons.link_off),
          label: const Text('Disconnect'),
        ),
        OutlinedButton.icon(
          onPressed: controller.forgetDevice,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Forget Device'),
        ),
      ],
    );
  }
}

class _TranscriptPanel extends StatelessWidget {
  const _TranscriptPanel({required this.controller});

  final LiveTranscriptionController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Transcript',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton.icon(
                onPressed: controller.clearTranscript,
                icon: const Icon(Icons.clear, color: Colors.white),
                label: const Text(
                  'Clear',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            controller.speechStatus,
            style: const TextStyle(
              color: Color(0xFFBAE6FD),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                controller.transcript.isEmpty
                    ? 'Transcription will appear here...'
                    : controller.transcript,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ),
          if (controller.confidence > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Confidence: ${(controller.confidence * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Color(0xFFD1FAE5),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ListenButton extends StatelessWidget {
  const _ListenButton({required this.controller});

  final LiveTranscriptionController controller;

  @override
  Widget build(BuildContext context) {
    final listening = controller.isListening;
    return SizedBox(
      height: 56,
      child: FilledButton.icon(
        onPressed: controller.toggleListening,
        icon: Icon(listening ? Icons.stop_circle : Icons.mic),
        label: Text(
          listening ? 'Stop Listening' : 'Start Listening',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: listening ? const Color(0xFFB00020) : const Color(0xFF00796B),
        ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.result,
    required this.onConnect,
  });

  final ScanResult result;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final advertised = result.advertisementData.advName;
    final name = advertised.isNotEmpty
        ? advertised
        : (result.device.platformName.isNotEmpty
            ? result.device.platformName
            : result.device.remoteId.str);

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(
        name,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text('RSSI ${result.rssi}'),
      trailing: TextButton(
        onPressed: onConnect,
        child: const Text('Connect'),
      ),
    );
  }
}

_ConnectionStatusStyle _statusStyle(GlassesConnectionState state) {
  switch (state) {
    case GlassesConnectionState.connected:
      return const _ConnectionStatusStyle(
        label: 'Connected',
        color: Color(0xFF0F766E),
        icon: Icons.bluetooth_connected,
      );
    case GlassesConnectionState.connecting:
    case GlassesConnectionState.reconnecting:
      return const _ConnectionStatusStyle(
        label: 'Connecting',
        color: Color(0xFFB45309),
        icon: Icons.sync,
      );
    case GlassesConnectionState.scanning:
      return const _ConnectionStatusStyle(
        label: 'Scanning',
        color: Color(0xFF1D4ED8),
        icon: Icons.bluetooth_searching,
      );
    case GlassesConnectionState.bluetoothOff:
      return const _ConnectionStatusStyle(
        label: 'Bluetooth Off',
        color: Color(0xFF991B1B),
        icon: Icons.bluetooth_disabled,
      );
    case GlassesConnectionState.permissionDenied:
      return const _ConnectionStatusStyle(
        label: 'Permission Needed',
        color: Color(0xFF7C2D12),
        icon: Icons.warning_amber_rounded,
      );
    case GlassesConnectionState.unsupported:
    case GlassesConnectionState.error:
      return const _ConnectionStatusStyle(
        label: 'Error',
        color: Color(0xFFB91C1C),
        icon: Icons.error_outline,
      );
    case GlassesConnectionState.disconnected:
      return const _ConnectionStatusStyle(
        label: 'Disconnected',
        color: Color(0xFF374151),
        icon: Icons.bluetooth,
      );
    case GlassesConnectionState.idle:
      return const _ConnectionStatusStyle(
        label: 'Idle',
        color: Color(0xFF4B5563),
        icon: Icons.bluetooth,
      );
  }
}

class _ConnectionStatusStyle {
  const _ConnectionStatusStyle({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}
