# frozen_string_literal: true

require 'mvi/responses/find_profile_response'
require 'common/models/redis_store'
require 'common/models/concerns/cache_aside'

# Facade for MVI. User model delegates MVI correlation id and VA profile (golden record) methods to this class.
# When a profile is requested from one of the delegates it is returned from either a cached response in Redis
# or from the MVI SOAP service.
class Mvi < Common::RedisStore
  include Common::CacheAside

  redis_config_key :mvi_profile_response

  # @return [User] the user to query MVI for.
  attr_accessor :user

  # Creates a new Mvi instance for a user.
  #
  # @param user [User] the user to query MVI for
  # @return [Mvi] an instance of this class
  def self.for_user(user)
    mvi = Mvi.new
    mvi.user = user
    mvi
  end

  # The status of the last MVI response or not authorized for for users < LOA 3
  #
  # @return [String] the status of the last MVI response
  def status
    return MVI::Responses::FindProfileResponse::RESPONSE_STATUS[:not_authorized] unless @user.loa3?
    mvi_response.status
  end

  # A DOD EDIPI (Electronic Data Interchange Personal Identifier) MVI correlation ID
  # or nil for users < LOA 3
  #
  # @return [String] the edipi correlation id
  def edipi
    return nil unless @user.loa3?
    profile&.edipi
  end

  # A ICN (Integration Control Number - generated by the Master Patient Index) MVI correlation ID
  # or nil for users < LOA 3
  #
  # @return [String] the icn correlation id
  def icn
    return nil unless @user.loa3?
    profile&.icn
  end

  # A ICN (Integration Control Number - generated by the Master Patient Index) MVI correlation ID
  # combined with its Assigning Authority ID.  Or nil for users < LOA 3.
  #
  # @return [String] the icn correlation id with its assigning authority id.
  #   For example:  '12345678901234567^NI^200M^USVHA^P'
  #
  def icn_with_aaid
    return nil unless @user.loa3?
    profile&.icn_with_aaid
  end

  # A MHV (My HealtheVet) MVI correlation id
  # or nil for users < LOA 3
  #
  # @return [String] the mhv correlation id
  def mhv_correlation_id
    return nil unless @user.loa3?
    profile&.mhv_correlation_id
  end

  # A VBA (Veterans Benefits Administration) or participant MVI correlation id.
  #
  # @return [String] the participant id
  def participant_id
    return nil unless @user.loa3?
    profile&.participant_id
  end

  # A BIRLS (Beneficiary Identification and Records Locator System) MVI correlation id.
  #
  # @return [String] the birls id
  def birls_id
    return nil unless @user.loa3?
    profile&.birls_id
  end

  # A Vet360 Correlation ID
  #
  # @return [String] the Vet360 id
  def vet360_id
    return nil unless @user.loa3?
    profile&.vet360_id
  end

  # A list of ICN's that the user has been identitfied by historically
  #
  # @return [Array[String]] the list of historical icns
  def historical_icns
    return nil unless @user.loa3?
    profile&.historical_icns
  end

  # The profile returned from the MVI service. Either returned from cached response in Redis or the MVI service.
  #
  # @return [MVI::Models::MviProfile] patient 'golden record' data from MVI
  def profile
    return nil unless @user.loa3?
    mvi_response&.profile
  end

  # @return [MVI::Responses::FindProfileResponse] the response returned from MVI
  def mvi_response
    @mvi_response ||= response_from_redis_or_service
  end

  private

  def response_from_redis_or_service
    do_cached_with(key: @user.uuid) do
      mvi_service.find_profile(@user)
    end
  end

  def mvi_service
    @service ||= MVI::Service.new
  end
end
