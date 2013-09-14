module Transmission
  module RPC
    # A nice wrapper around Transmission's RPC
    class Torrent

      attr_accessor :activity_date, :added_date, :bandwidth_priority, :comment, :corrupt_ever, :creator, :date_created,
        :desired_available, :done_date, :download_dir, :downloaded_ever, :download_limit, :download_limited, :error,
        :error_string, :eta, :eta_idle, :files, :file_stats, :hash_string, :have_unchecked,
        :have_valid, :honors_session_limits, :id, :is_finished, :is_private, :is_stalled, :left_until_done,
        :magnet_link, :manual_announce_time, :max_connected_peers, :metadata_percent_complete, :name, :peer_limit, :peers,
        :peers_connected, :peers_from, :peers_getting_from_us, :peers_sending_to_us, :percent_done, :pieces, :piece_count,
        :piece_size, :priorities, :queue_position, :rate_download, :rate_upload, :recheck_progress, :seconds_downloading,
        :seconds_seeding, :seed_idle_limit, :seed_idle_mode, :seed_ratio_limit, :seed_ratio_mode, :size_when_done, :start_date,
        :status, :trackers, :tracker_stats, :total_size, :torrent_file, :uploaded_ever, :upload_limit,
        :upload_limited, :upload_ratio, :wanted, :webseeds, :webseeds_sending_to_us
 
      include Transmission::RPC

      def initialize(options = {})
        self.activity_date             = options['activityDate']
        self.added_date                = options['addedDate']
        self.bandwidth_priority        = options['bandwidthPriority']
        self.comment                   = options['comment']
        self.corrupt_ever              = options['corruptEver']
        self.creator                   = options['creator']
        self.date_created              = options['dateCreated']
        self.desired_available         = options['desiredAvailable']
        self.done_date                 = options['doneDate']
        self.download_dir              = options['downloadDir']
        self.downloaded_ever           = options['downloadedEver']
        self.download_limit            = options['downloadLimit']
        self.download_limited          = options['downloadLimited']
        self.error                     = options['error']
        self.error_string              = options['errorString']
        self.eta                       = options['eta']
        self.eta_idle                  = options['etaIdle']
        self.files                     = options['files']
        self.file_stats                = options['fileStats']
        self.hash_string               = options['hashString']
        self.have_unchecked            = options['haveUnchecked']
        self.have_valid                = options['haveValid']
        self.honors_session_limits     = options['honorsSessionLimits']
        self.id                        = options['id']
        self.is_finished               = options['isFinished']
        self.is_private                = options['isPrivate']
        self.is_stalled                = options['isStalled']
        self.left_until_done           = options['leftUntilDone']
        self.magnet_link               = options['magnetLink']
        self.manual_announce_time      = options['manualAnnounceTime']
        self.max_connected_peers       = options['maxConnectedPeers']
        self.metadata_percent_complete = options['metadataPercentComplete']
        self.name                      = options['name']
        self.peer_limit                = options['peer-limit']
        self.peers                     = options['peers']
        self.peers_connected           = options['peersConnected']
        self.peers_from                = options['peersFrom']
        self.peers_getting_from_us     = options['peersGettingFromUs']
        self.peers_sending_to_us       = options['peersSendingToUs']
        self.percent_done              = options['percentDone']
        self.pieces                    = options['pieces']
        self.piece_count               = options['pieceCount']
        self.piece_size                = options['pieceSize']
        self.priorities                = options['priorities']
        self.queue_position            = options['queuePosition']
        self.rate_download             = options['rateDownload']
        self.rate_upload               = options['rateUpload']
        self.recheck_progress          = options['recheckProgress']
        self.seconds_downloading       = options['secondsDownloading']
        self.seconds_seeding           = options['secondsSeeding']
        self.seed_idle_limit           = options['seedIdleLimit']
        self.seed_idle_mode            = options['seedIdleMode']
        self.seed_ratio_limit          = options['seedRatioLimit']
        self.seed_ratio_mode           = options['seedRatioMode']
        self.size_when_done            = options['sizeWhenDone']
        self.start_date                = options['startDate']
        self.status                    = options['status']
        self.trackers                  = options['trackers']
        self.tracker_stats             = options['trackerStats']
        self.total_size                = options['totalSize']
        self.torrent_file              = options['torrentFile']
        self.uploaded_ever             = options['uploadedEver']
        self.upload_limit              = options['uploadLimit']
        self.upload_limited            = options['uploadLimited']
        self.upload_ratio              = options['uploadRatio']
        self.wanted                    = options['wanted']
        self.webseeds                  = options['webseeds']
        self.webseeds_sending_to_us    = options['webseedsSendingToUs']
      end

      # Starts downloading the current torrent
      def start!
        Client.request("torrent-start", nil, [self.id])
      end

      # Stops downloading the current torrent
      def stop!
        Client.request("torrent-stop", nil, [self.id])
      end

      # Deletes the current torrent, and, optionally, the data for that torrent
      def delete!(delete_data = false)
        Client.request("torrent-remove", { :delete_local_data => delete_data }, [self.id])
      end

      # Checks if torrent is currently downloading
      def downloading?
        self.status == 4
      end

      # Checks if torrent is paused 
      def paused?
        self.status == 0
      end

      # Adds a torrent by URL or file path
      def self.+(url)
        self.add(:url => url)
      end

      # Gets all the torrents
      def self.all
        @unprocessed_torrents = Client.request("torrent-get", { :fields => self.fields })['arguments']['torrents']
        @unprocessed_torrents.collect { |torrent| self.new(torrent) }				
      end

      # Finds a torrent by ID
      def self.find(id)
        @unprocessed_response = Client.request("torrent-get", { :fields => self.fields }, [id])
        @torrents = @unprocessed_response['arguments']['torrents']
        if @torrents.count > 0
          return self.new(@torrents.first)
        else
          return nil
        end
      end

      # Adds a torrent by file path or URL (.torrent file's only right now)
      def self.add(options = {})
        @response = nil
        if options[:metainfo]
          @response = Client.request("torrent-add", :metainfo => options[:metainfo])
        else
          @response = Client.request("torrent-add", :filename => options[:url])
        end

        if @response['result'] == 'success'
          self.find(@response['arguments']['torrent-added']['id'])
        else
          nil
        end
      end

      # Starts all torrents
      def self.start!
        Client.request "torrent-start"
      end

      # Stops all torrents
      def self.stop!
        Client.request "torrent-stop"
      end

      private

      # The accessors for a torrent, the way that Transmission's RPC likes them.
      def self.fields
        @fields ||= 
          ['activityDate',
           'addedDate',
           'bandwidthPriority',
           'comment',
           'corruptEver',
           'creator',
           'dateCreated',
           'desiredAvailable',
           'doneDate',
           'downloadDir',
           'downloadedEver',
           'downloadLimit',
           'downloadLimited',
           'error',
           'errorString',
           'eta',
           'etaIdle',
           'files',
           'fileStats',
           'hashString',
           'haveUnchecked',
           'haveValid',
           'honorsSessionLimits',
           'id',
           'isFinished',
           'isPrivate',
           'isStalled',
           'leftUntilDone',
           'magnetLink',
           'manualAnnounceTime',
           'maxConnectedPeers',
           'metadataPercentComplete',
           'name',
           'peer-limit',
           'peers',
           'peersConnected',
           'peersFrom',
           'peersGettingFromUs',
           'peersSendingToUs',
           'percentDone',
           'pieces',
           'pieceCount',
           'pieceSize',
           'priorities',
           'queuePosition',
           'rateDownload',
           'rateUpload',
           'recheckProgress',
           'secondsDownloading',
           'secondsSeeding',
           'seedIdleLimit',
           'seedIdleMode',
           'seedRatioLimit',
           'seedRatioMode',
           'sizeWhenDone',
           'startDate',
           'status',
           'trackers',
           'trackerStats',
           'totalSize',
           'torrentFile',
           'uploadedEver',
           'uploadLimit',
           'uploadLimited',
           'uploadRatio',
           'wanted',
           'webseeds',
           'webseedsSendingToUs']
      end

    end
  end
end
