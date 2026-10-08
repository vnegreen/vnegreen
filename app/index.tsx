// Native iOS/Android: WebView tải toàn bộ VNEGREEN Super App
import { useRef, useState, useCallback } from 'react';
import { View, StyleSheet, Pressable, Text, ActivityIndicator, BackHandler } from 'react-native';
import { WebView, WebViewNavigation } from 'react-native-webview';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect } from 'expo-router';

// URL của VNEGREEN Super App (web version)
const TARGET_URL = 'https://demo.nlpgroup.vn/';

export default function IndexScreen() {
  const webViewRef = useRef<WebView>(null);
  const insets = useSafeAreaInsets();
  const [canGoBack, setCanGoBack] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useFocusEffect(
    useCallback(() => {
      const onBack = () => {
        if (canGoBack && webViewRef.current) {
          webViewRef.current.goBack();
          return true;
        }
        return false;
      };
      BackHandler.addEventListener('hardwareBackPress', onBack);
      return () => BackHandler.removeEventListener('hardwareBackPress', onBack);
    }, [canGoBack])
  );

  if (error) {
    return (
      <View style={[styles.errorBox, { paddingTop: insets.top }]}>
        <Text style={styles.errorIcon}>⚡</Text>
        <Text style={styles.errorTitle}>Không thể kết nối</Text>
        <Text style={styles.errorSub}>{error}</Text>
        <Pressable
          style={styles.retryBtn}
          onPress={() => { setError(null); setLoading(true); webViewRef.current?.reload(); }}
        >
          <Text style={styles.retryText}>Thử lại</Text>
        </Pressable>
      </View>
    );
  }

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <WebView
        ref={webViewRef}
        source={{ uri: TARGET_URL }}
        style={{ flex: 1 }}
        onNavigationStateChange={(nav: WebViewNavigation) => setCanGoBack(nav.canGoBack)}
        onLoadStart={() => setLoading(true)}
        onLoadEnd={() => setLoading(false)}
        onError={(e) => { setLoading(false); setError(e.nativeEvent.description); }}
        javaScriptEnabled
        domStorageEnabled
        allowsInlineMediaPlayback
        mediaPlaybackRequiresUserAction={false}
        geolocationEnabled
        mixedContentMode="compatibility"
        cacheEnabled
        pullToRefreshEnabled
        allowsFullscreenVideo
        userAgent="Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36 VNEGREEN/1.0"
        renderLoading={() => (
          <View style={styles.loading}>
            <ActivityIndicator size="large" color="#00E599" />
            <Text style={styles.loadingText}>Đang tải VNEGREEN...</Text>
          </View>
        )}
        startInLoadingState
      />

      {/* Bottom Navigation Bar */}
      <View style={[styles.bottomBar, { paddingBottom: insets.bottom || 8 }]}>
        <Pressable
          style={[styles.btn, !canGoBack && { opacity: 0.3 }]}
          onPress={() => webViewRef.current?.goBack()}
          disabled={!canGoBack}
        >
          <Text style={styles.btnText}>◄</Text>
        </Pressable>
        <Pressable style={styles.btn} onPress={() => webViewRef.current?.reload()}>
          <Text style={styles.btnText}>↻</Text>
        </Pressable>
        <Pressable
          style={styles.btn}
          onPress={() => webViewRef.current?.injectJavaScript(`window.location.href='${TARGET_URL}';true;`)}
        >
          <Text style={styles.btnText}>⌂</Text>
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#080C15' },
  loading: {
    position: 'absolute',
    top: 0, left: 0, right: 0, bottom: 0,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#080C15',
    gap: 12,
  },
  loadingText: { color: '#00E599', fontSize: 13, fontWeight: '600' },
  errorBox: {
    flex: 1,
    backgroundColor: '#080C15',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 12,
    padding: 32,
  },
  errorIcon: { fontSize: 52 },
  errorTitle: { color: '#f1f5f9', fontSize: 18, fontWeight: '700' },
  errorSub: { color: '#64748b', fontSize: 12, textAlign: 'center' },
  retryBtn: {
    backgroundColor: '#10b981',
    paddingHorizontal: 28,
    paddingVertical: 12,
    borderRadius: 14,
    marginTop: 8,
  },
  retryText: { color: '#051B11', fontWeight: '700', fontSize: 14 },
  bottomBar: {
    flexDirection: 'row',
    backgroundColor: '#0E1626',
    borderTopWidth: 1,
    borderTopColor: '#1E293B',
    paddingTop: 8,
    paddingHorizontal: 16,
  },
  btn: { flex: 1, alignItems: 'center', paddingVertical: 8 },
  btnText: { color: '#e2e8f0', fontSize: 20 },
});
