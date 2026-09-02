/// Ownership is a domain fact, not a permission badge.
enum ArtifactOwner { xiaxia, user, shared }

class OwnedArtifact<T> {
  const OwnedArtifact({required this.owner, required this.value});

  final ArtifactOwner owner;
  final T value;

  /// Shared ownership must be created explicitly for a genuinely co-created item.
  factory OwnedArtifact.shared(T value) {
    return OwnedArtifact<T>(owner: ArtifactOwner.shared, value: value);
  }
}
