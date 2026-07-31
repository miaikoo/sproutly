/// One purchasable accessory. Emoji stands in for real art until the
/// companion has actual wearable assets to render.
class StoreItem {
  const StoreItem({required this.id, required this.name, required this.emoji, required this.cost});

  final String id;
  final String name;
  final String emoji;
  final int cost;
}

/// Placeholder catalog for the Sprout Store (Toko Aksesoris). Swap for a
/// Firestore-backed catalog once there's real accessory art to sell.
const storeCatalog = [
  StoreItem(id: 'overalls', name: 'Overall Bunga', emoji: '🌼', cost: 20),
  StoreItem(id: 'hat', name: 'Topi Kebun', emoji: '👒', cost: 30),
  StoreItem(id: 'scarf', name: 'Syal Hangat', emoji: '🧣', cost: 25),
  StoreItem(id: 'glasses', name: 'Kacamata Lucu', emoji: '🕶️', cost: 15),
  StoreItem(id: 'boots', name: 'Sepatu Boot', emoji: '👢', cost: 35),
  StoreItem(id: 'umbrella', name: 'Payung Kecil', emoji: '☂️', cost: 20),
  StoreItem(id: 'crown', name: 'Mahkota Bunga', emoji: '🌸', cost: 40),
  StoreItem(id: 'backpack', name: 'Tas Kecil', emoji: '🎒', cost: 30),
];
