package de.komoot.photon.config;

import com.beust.jcommander.Parameter;
import org.jspecify.annotations.NullMarked;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

@NullMarked
public class PhotonDBConfig {
    public static final String GROUP = "Photon database options";

    public PhotonDBConfig(String dataDirectory, String cluster, List<String> transportAddresses) {
        this(dataDirectory, cluster, transportAddresses, null, null);
    }

    public PhotonDBConfig(String dataDirectory, String cluster, List<String> transportAddresses,
                          @org.jspecify.annotations.Nullable String clusterLogin,
                          @org.jspecify.annotations.Nullable String clusterPassword) {
        this.dataDirectory = dataDirectory;
        this.cluster = cluster;
        this.transportAddresses = transportAddresses;
        this.clusterLogin = clusterLogin;
        this.clusterPassword = clusterPassword;
    }

    public PhotonDBConfig() {
    }

    @Parameter(names = "-data-dir", category = GROUP, placeholder = "DIR", description = """
            Data directory to use when using the internal server
            """)
    private String dataDirectory = new File(".").getAbsolutePath();

    @Parameter(names = "-transport-addresses", category = GROUP, placeholder = "ADDR,..", description = """
            Comma-separated list of addresses of external OpenSearch nodes the client can connect to;
            when left empty, then an internal server is started and used
            """)
    private List<String> transportAddresses = new ArrayList<>();

    @Parameter(names = "-cluster", category = GROUP, placeholder = "NAME", description = """
            Name of the database cluster to use for the Photon database
            """)
    private String cluster = "photon";

    @Parameter(names = "-cluster-login", category = GROUP, placeholder = "USER", description = """
            Username for HTTP basic auth against an external OpenSearch cluster
            """)
    @org.jspecify.annotations.Nullable
    private String clusterLogin = null;

    @Parameter(names = "-cluster-password", category = GROUP, placeholder = "PASSWORD", description = """
            Password for HTTP basic auth against an external OpenSearch cluster
            """)
    @org.jspecify.annotations.Nullable
    private String clusterPassword = null;

    @Parameter(names = "-index-name", category = GROUP, placeholder = "NAME", description = """
            Name of the OpenSearch index to read from / write to (default: photon)
            """)
    private String indexName = "photon";

    public String getDataDirectory() {
        return this.dataDirectory;
    }

    public String getCluster() {
        return this.cluster;
    }

    public List<String> getTransportAddresses() {
        return this.transportAddresses;
    }

    @org.jspecify.annotations.Nullable
    public String getClusterLogin() {
        return this.clusterLogin;
    }

    @org.jspecify.annotations.Nullable
    public String getClusterPassword() {
        return this.clusterPassword;
    }

    public String getIndexName() {
        return this.indexName;
    }
}
