class ProductsController < ApplicationController
  before_action :authenticate_admin_user!, only: [:new,:create]


	def new
		@product = Product.new
	end

	def create 
    if params[:product][:category_id].present? and params[:product][:assetclass_id].present?
		  assetclass_id = Category.find_by(id: params[:product][:category_id]).assetclass_id
		  params_merged = product_params.merge(assetclass_id: assetclass_id)
    end
		@product = Product.new(params_merged)
		if @product.save
      		flash[:success] = "Produto criado com sucesso!"
      		redirect_to @product		
		else
      		flash[:error] = "Não foi possivel criar o produto, tente novamente!"
          render 'new'
		end
	end


	def index
		#if params[:assetclass_id]
		#	@products = Product.where(assetclass_id: params[:assetclass_id])
		#end
		#if params[:category_id]
			#@products = Product.where(category_id: params[:category_id])
		#end
		

		#@products = Product.includes(:product_associates, :category)
    	#if params and params["/products"] and params["/products"]["search_category"]
      	#	@products = Category.find_by(name: params["/products"]["search_category"]).products.where(id: params["/products"]["search_product_id"]).includes(:product_associates, :category).order(updated_at: :desc)
    	#end

    	#if params and params["/products"] and params["/products"]["management_firm"] and params["/products"]["category_name"] and params["/products"]["target_return_benchmark_to"]
    	#	category_id = Category.find_by(name: params["/products"]["category_name"]).id
    	#	@products = Product.where(['target_return_benchmark_to > ? and category_id = ? and management_firm = ?', params["/products"]["target_return_benchmark_to"], category_id, params["/products"]["management_firm"]])
    	#print "---------------"
    	#print params["/products"]["management_firm"]
    	#print params["/products"]["category_name"]
    	#print params["/products"]["target_return_benchmark_to"]

    	#end
		

    	if params and params["/products"] and params["/products"]["management_firm"] and params["/products"]["category_name"] and params["/products"]["target_return_benchmark_to"]
    		@products = Product.filter_1 params
    	elsif params[:category_id]
    		@products = Product.where(category_id: params[:category_id], view_status: "público")
    	elsif params[:category_id] and current_user.reserved_relations.present?
    		@all_category_products = Product.where(category_id: params[:category_id], view_status: "público")    		
    		product_ids_from_reserved_relations = current_user.reserved_relations.pluck(:product_id)	 
    		@all_reserved_products = Product.where(id: product_ids_from_reserved_relations )
    		@products =  @all_reserved_products + @all_category_products    		
    	elsif current_user.reserved_relations.present?
    		@all_products = Product.where(view_status: "público")
    		product_ids_from_reserved_relations = current_user.reserved_relations.pluck(:product_id)	 
    		@all_reserved_products = Product.where(id: product_ids_from_reserved_relations )
    		@products =  @all_reserved_products + @all_products
    	else
    		@products = Product.where(view_status: "público")
    	end

      @products
      if params[:table_format]
        render 'table_index'
      end






		#if params and params['search_irr']  
		#	@products = Product.joins(:product_specific).where("product_specifics.irr_to > ?", params["/products"]["search_irr"])
		#end

	end

	def show
		if params[:id]
			@product = Product.find_by(id: params[:id])	unless Product.find_by(id: params[:id], view_status: "confidencial") and !ReservedRelation.where(user_id: current_user.id, product_id: params[:id]).present?
			current_user_segmentations = current_user.segmentation
			if current_user.customer_to_product_associates.present?
				@product_associates = @product.product_associates.joins(:customer_to_product_associates).where("customer_to_product_associates.user_id = ?", current_user.id)
			else
				@product_associates = @product.product_associates.joins(:user).where("users.segmentation@> ARRAY[?]::varchar[]", current_user_segmentations)
			end
			@posts = @product.posts.order(created_at: :desc)
		end
	end


  def edit
    @product = Product.find_by(id: params[:id])
  end

  def update
    @product = Product.find_by(id: params[:id])
    if @product.update(product_params)
      flash[:success] = "Produto atualizado com sucesso!"
      redirect_to product_path(@product)
    else
      flash[:erro] = "Não foi possível atualizar o produto. Por favor tente novamente"
      redirect_to product_path(@product)
    end
  end	

  def import
    Product.import(params[:file])
    flash[:success] = "Importação feita com sucesso"
    redirect_back(fallback_location: root_path) 

  end  


	private



	def product_params
		params.require(:product).permit(:view_status ,:name, :description, :category_id, :assetclass_id, :firm_id, :admin_fee, :performance_fee, :status, :other_obs, :target_return_benchmark_from, :target_return_benchmark_to, :country, :from_investment_period, :to_investment_period, :manager, :administrator, :destribuitor, :cnpj, :inception_date, :minimal_investment, :maximum_investment,:target_investor, :benchmark ,videos:[], images:[], releases:[], documents:[], 
		product_specific_attributes: [ :deal_size_from, :deal_size_to, :closing_expected, :net_debt, :investment_structure, :irr_from, :irr_to, :coc_from, :coc_to, :deal_size, :deal_size_t, :stake_offered_from, :stake_offered_to, :revenue_from, :revenue_to, :ebtida_from, :ebtida_to ]
			)
	end




end
