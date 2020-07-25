class CloudBaseInstanceDoesNotExists extends Error {
  String envId;

  String get message => "CloudBase instance($envId) don't exists.";

  CloudBaseInstanceDoesNotExists(this.envId);
}
