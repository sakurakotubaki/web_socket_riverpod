// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$webSocketChannelHash() => r'0e4a99811b7c15342ff637f47926dd59c2270c75';

/// See also [webSocketChannel].
@ProviderFor(webSocketChannel)
final webSocketChannelProvider = AutoDisposeProvider<WebSocketChannel>.internal(
  webSocketChannel,
  name: r'webSocketChannelProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$webSocketChannelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WebSocketChannelRef = AutoDisposeProviderRef<WebSocketChannel>;
String _$webSocketStreamHash() => r'8252f605e914959195d2388c78ed2ed9d2d46695';

/// See also [webSocketStream].
@ProviderFor(webSocketStream)
final webSocketStreamProvider = AutoDisposeStreamProvider<String>.internal(
  webSocketStream,
  name: r'webSocketStreamProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$webSocketStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WebSocketStreamRef = AutoDisposeStreamProviderRef<String>;
String _$messagesHash() => r'413dcad25b6517de5230e7f1f2ffdce157bdb3b7';

/// See also [Messages].
@ProviderFor(Messages)
final messagesProvider =
    AutoDisposeNotifierProvider<Messages, List<Message>>.internal(
      Messages.new,
      name: r'messagesProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product') ? null : _$messagesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Messages = AutoDisposeNotifier<List<Message>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
