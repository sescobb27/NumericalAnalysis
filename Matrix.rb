#!/usr/bin/env ruby -wKU
require "awesome_print"
class Matrix
      attr_accessor :matriz,:n,:m
      attr_reader :simetrica
      def initialize(n,m,matriz = nil)
            @n = n
            @m = m
            if matriz
                  @matriz = matriz
            else
                  @matriz = Array.new(n){ Array.new(m) }
                  entrar_datos
                  @transpuesta = nil
                  @simetrica = nil
                  @t_superior = nil
                  transpuesta
                  simetrica?
            end
            self
      end

      def entrar_datos
            # 0.upto(@n - 1) do |i|
            #       0.upto(@m - 1) do |j|
            #              puts "ingrese datos:"
            #              dato = gets.to_i
            #              @matriz[i][j] = dato
            #       end
            # end
            # @matriz = [ [14,6,-2,3,12], [3,15,2,-5,32], [-7,4,-23,2,-24], [1,-3,-2,16,14] ]
            # @matriz = [ [-7,2,-3,4,-12], [5,-1,14,-1,13], [1,9,-7,5,31], [-12,13,-8,-4,-32] ]
            @matriz = [ [-7,2,-3,4,-12], [5,-1,14,-1,13], [1,9,-7,13,31], [-12,13,-8,-4,-32] ]
      end

      def self.imprimir matrix
            puts "Matriz Original:"
            0.upto(matrix.n - 1) do |i|
                  0.upto(matrix.m - 1) do |j|
                        # print "#{matrix.matriz[i][j]} "
                        printf "[%4f]",matrix.matriz[i][j]
                  end
                  puts ""
            end
      end

      def equals? matrix
            if  (@n != matrix.n) || (@m != matrix.m)
                  return false
            end
            0.upto(@n - 1) do |i|
                  0.upto(@m - 1) do |j|
                        unless @matriz[i][j] == matrix.matriz[i][j]
                              return false
                        end
                  end
            end
            true
      end

      def multiplicar matrix
            unless @m == matrix.n
                  puts "No se puede multiplicar, las columnas de A tienen que
                  tener la misma longitud que las filas de B"
                  return
            end
            temp = Array.new(@n,0) { Array.new(matrix.m,0) }
            0.upto(@n - 1) do |i|
                  matrix.m.times do |j|
                        0.upto(@m - 1) do |k|
                              temp[i][j] += @matriz[i][k] * matrix.matriz[k][j]
                        end
                  end
            end
            Matrix.new(temp.size,temp[0].size,temp)
      end

      def suma matrix
            unless @m == matrix.m and @n == matrix.n
                  puts "No se puede sumar, las longitudes tienen que ser iguales"
                  return
            end
            temp = Array.new(@n,0) { Array.new(@m,0) }
            0.upto(@n - 1) do |i|
                  0.upto(@m - 1) do |j|
                        temp[i][j] += @matriz[i][j] + matrix.matriz[i][j]
                  end
            end
            Matrix.new(temp.size,temp[0].size,temp)
      end

      def transpuesta
            unless @transpuesta
                   temp = Array.new(@m){ 
                          Array.new(@n) 
                   }
                  0.upto(@m - 1) do |i|
                          0.upto(@n - 1) do |j|
                                temp[i][j] = @matriz[j][i]
                          end
                  end
                  @transpuesta = Matrix.new(temp.size,temp[0].size,temp)
            end
            @transpuesta
      end

      def simetrica?
            return @simetrica unless @simetrica.nil?
            unless @transpuesta
                  transpuesta
            end
            if matriz.equal? @transpuesta
                  0.upto(@n - 1) do |i|
                        0.upto(@m - 1) do |j|
                              unless matriz[i][j] == matriz[j][i]
                                    return @simetrica = false
                              end
                        end
                  end
                  return @simetrica = true
            end
            @simetrica = false
      end

      def gauss_simple pos_i = 0, pos_j = 0
            return if pos_i >= @n - 1 || pos_j >= @m - 1
            unless @matriz[pos_i][pos_j].zero?
                  temp = pos_i
                  while temp < @n - 1 do
                          multiplicador = (@t_superior.matriz[temp + 1][pos_j]).fdiv(@t_superior.matriz[pos_i][pos_j])
                          vector1 = @t_superior.matriz[pos_i].map { |value| value * multiplicador }
                          @t_superior.matriz[temp + 1].map! { |value| value - vector1.shift }
                          temp += 1
                  end
            end
            gauss_simple pos_i + 1, pos_j + 1
      end

      def triangular_superior
            if @t_superior.nil?
                   @t_superior ||= self.clone
                   gauss_simple
            end
            @t_superior
      end

      def mayor_valor_fila matrix, fila, columna
             mayor = matrix.matriz[fila][columna].abs
             _fila = fila
             pos = fila
             while _fila < matrix.n
                   value = matrix.matriz[_fila][columna]
                   if value.abs > mayor then mayor = value ; pos = _fila end
                   _fila += 1
             end
             return mayor, pos
      end

      def triangular_superior_pivoteo
            if @t_superior.nil?
                   @t_superior ||= self.clone
                   # pivoteo_parcial
                   pivoteo_total
            end
            @t_superior
      end

      def pivoteo_parcial pos_i = 0, pos_j = 0
            return if pos_i >= @n - 1 || pos_j >= @m - 1
            temp = pos_i
            mayor, fila = mayor_valor_fila @t_superior, temp, pos_j
            raise "No hay solucion unica" if mayor == 0
            @t_superior.matriz[pos_i], @t_superior.matriz[fila] = @t_superior.matriz[fila], @t_superior.matriz[pos_i]
            while temp < @n - 1 do
                  multiplicador = (@t_superior.matriz[temp + 1][pos_j]).fdiv( mayor )
                  vector1 = @t_superior.matriz[pos_i].map { |value| value * multiplicador }
                  @t_superior.matriz[temp + 1].map! { |value| value - vector1.shift }
                  temp += 1
            end
            pivoteo_parcial pos_i + 1, pos_j + 1
      end

      def seleccionar_mayor matrix, from_fila, from_col
        mayor = matrix.matriz[from_fila][from_col];
        pos_fila  = from_fila
        pos_columna = from_col
        matriz = matrix.matriz
        for fila in from_fila ... @n
          for columna in from_col ... ( @m - 1)
            value = matriz[fila][columna]
            if value.abs > mayor 
              mayor = value
              pos_fila = fila
              pos_columna = columna
            end
          end
        end
        return mayor, pos_fila, pos_columna
      end

      def rotar_columnas matrix, mayor, from_fila, from_col, col_mayor
        for _fila in from_fila ... @n
          matrix.matriz[_fila][from_col], matrix.matriz[_fila][col_mayor] =
                          matrix.matriz[_fila][col_mayor], matrix.matriz[_fila][from_col]
        end
      end

      def pivoteo_total pos_i = 0, pos_j = 0
        x_vector ||= (1 .. @n).to_a
        return if pos_i >= @n - 1 || pos_j >= @m - 1
        mayor, fila_mayor, col_mayor = seleccionar_mayor @t_superior, pos_i, pos_j 
        @t_superior.matriz[pos_i], @t_superior.matriz[fila_mayor] =
                          @t_superior.matriz[fila_mayor], @t_superior.matriz[pos_i]
        rotar_columnas @t_superior, mayor, pos_i, pos_j, col_mayor
        temp = pos_i
        raise "No hay solucion unica" if mayor == 0
        while temp < @n - 1 do
              multiplicador = (@t_superior.matriz[temp + 1][pos_j]).fdiv( mayor )
              vector1 = @t_superior.matriz[pos_i].map { |value| value * multiplicador }
              @t_superior.matriz[temp + 1].map! { |value| value - vector1.shift }
              temp += 1
        end
        Matrix.imprimir @t_superior
        pivoteo_total pos_i + 1, pos_j + 1
      end

      def triangular_inferior
        
      end
end

test = Matrix.new 4, 5
# Matrix.imprimir test
# Matrix.imprimir test.transpuesta
# Matrix.imprimir test.triangular_superior
# Matrix.imprimir test.triangular_superior_pivoteo
Matrix.imprimir test.triangular_superior_pivoteo
